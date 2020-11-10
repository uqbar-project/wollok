package org.uqbar.project.wollok.ui.diagrams.classes

import java.util.Comparator
import java.util.List
import java.util.Map
import java.util.Observable
import java.util.Observer
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.PositionConstants
import org.eclipse.draw2d.graph.DirectedGraph
import org.eclipse.draw2d.graph.DirectedGraphLayout
import org.eclipse.draw2d.graph.Edge
import org.eclipse.draw2d.graph.Node
import org.eclipse.emf.common.util.URI
import org.eclipse.gef.DefaultEditDomain
import org.eclipse.gef.EditPart
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.commands.CommandStack
import org.eclipse.gef.editparts.AbstractGraphicalEditPart
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart
import org.eclipse.gef.editparts.ZoomManager
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.gef.ui.actions.ZoomComboContributionItem
import org.eclipse.gef.ui.properties.UndoablePropertySheetPage
import org.eclipse.gef.ui.views.palette.PalettePage
import org.eclipse.jface.action.Separator
import org.eclipse.jface.text.DocumentEvent
import org.eclipse.jface.text.IDocumentListener
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.progress.UIJob
import org.eclipse.ui.views.properties.IPropertySheetPage
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.XtextDocumentUtil
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.ui.diagrams.AbstractDiagramView
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.AddOutsiderClass
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.CleanAllRelashionshipsAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.CleanShapePositionsAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.DeleteAllOutsiderClasses
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.DeleteElementAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ExportAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.RememberShapePositionsToggleButton
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowFileAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowHiddenComponents
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowHiddenParts
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowHiddenPartsElementAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowVariablesToggleButton
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.NamedObjectModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.model.StaticDiagram
import org.uqbar.project.wollok.ui.diagrams.classes.palette.CustomPalettePage
import org.uqbar.project.wollok.ui.diagrams.classes.palette.StaticDiagramPaletterFactory
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.ClassEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.InheritanceConnectionEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.MixinEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.NamedObjectEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.StaticDiagramEditPartFactory
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * Main view for static diagrams. Here we show
 * - classes
 * - named objects
 * - mixins
 * and its relationships, that includes inheritance, association and dependency.
 * 
 * GEF tutorials: http://www.redbooks.ibm.com/redbooks/pdfs/sg246302.pdf
 *  
 * @author jfernandes
 * @author dodain
 * 
 */
class StaticDiagramView extends AbstractDiagramView implements IDocumentListener, Observer {

	IXtextDocument xtextDocument

	// Toolbar - actions
	ExportAction exportAction

	// Static diagram state and configuration
	StaticDiagramConfiguration configuration

	new() {
		editDomain = new DefaultEditDomain(null)
		editDomain.paletteRoot = StaticDiagramPaletterFactory.create
		configuration = new StaticDiagramConfiguration
		configuration.addObserver(this)
		Shape.useConfiguration(configuration)
	}

	def createDiagramModel() {
		// dodain - Enhanced performance
		// Don't create diagram if you are editing a file 
		// that is not supposed to be synchronized with a static diagram (eg: tests files)
		// or if static diagram was disposed
		if (!configuration.resourceIsForStaticDiagram || splitter.isDisposed) {
			return new StaticDiagram(configuration, #[])
		}

		new StaticDiagram(configuration, xtextDocument.readOnly[allElements].toList) => [
			// all objects
			val objects = xtextDocument.readOnly[namedObjects]

			// all mixins
			val mixins = xtextDocument.readOnly[mixins]

			// hierarchy level
			// all classes and named objects inheriting from a class
			// new way: instead of adding imports we just detect them because of hierarchy
			val classes = xtextDocument.readOnly[classes]
			val Map<URI, List<WMethodContainer>> mapOutsiderMethodContainers = configuration.resource.project.
				mapMethodContainers(configuration.isPlatformFile)
			val outsiderElements = configuration.outsiderElements.map [ outsiderElement |
				mapOutsiderMethodContainers.get(outsiderElement.realURI)?.findFirst [
					outsiderElement.identifier.equals(it.identifier)
				]
			].filter[it !== null].toList

			// Now let's collect all elements
			val staticDiagramBuilder = new StaticDiagramBuilder().addElements(mixins).addElements(objects).
				addElements(classes).addElements(outsiderElements)

			val allHierarchyElements = staticDiagramBuilder.allElements

			ClassModel.init(allHierarchyElements)

			// Drawing the Static Diagram
			// First isolated Objects without parents
			val singleObjects = staticDiagramBuilder.allSingleObjects.filter[!configuration.isHiddenComponent(name)]

			singleObjects.forEach [ o |
				addNamedObject(new NamedObjectModel(o as WNamedObject) => [
					locate
				])
			]

			// then, all mixins
			staticDiagramBuilder.allMixins.filter[WMixin m|!configuration.isHiddenComponent(m.identifier)].forEach [ WMixin m |
				addMixin(m)
			]

			// then, classes
			// first, superclasses
			var classesCopy = allHierarchyElements.clone.filter[it.parent === null].sortWith(
				methodContainerDefaultComparator).toList

			var int level = 0
			while (!classesCopy.isEmpty) {
				val levelCopy = level
				classesCopy.forEach[c|addComponent(c, levelCopy)]
				val parentClasses = classesCopy
				// then subclasses of parent classes and recursively...
				classesCopy = allHierarchyElements.clone.filter [
					parentClasses.contains(it.parent)
				].sortWith(methodContainerDefaultComparator).toList

				level++
			}

			// relations
			connectInheritanceRelations
			connectRelations
		]
	}

	def methodContainerDefaultComparator() {
		[ WMethodContainer a, WMethodContainer b |
			val orderForA = (a.parent?.identifier ?: "") + a.identifier
			val orderForB = (b.parent?.identifier ?: "") + b.identifier
			orderForA.compareTo(orderForB)
		] as Comparator<WMethodContainer>
	}

	override configureToolbar() {
		exportAction = new ExportAction => [
			viewer = graphicalViewer
		]
		val showVariablesToggleButton = new ShowVariablesToggleButton(Messages.StaticDiagram_Show_Variables,
			configuration)
		val rememberShapePositionsToggleButton = new RememberShapePositionsToggleButton(
			Messages.StaticDiagram_RememberShapePositions_Description, configuration)

		site.actionBars.toolBarManager => [
//			add(new ZoomComboContributionItem(site.workbenchWindow.activePage, #{
//				ZoomManager.FIT_ALL,
//				ZoomManager.FIT_HEIGHT,
//				ZoomManager.FIT_WIDTH
//			} as String[]))
			add(zoomIn)
			add(zoomOut)
			add(new ShowFileAction("labelFile", configuration))
			add(new Separator)
			add(exportAction)
			add(new Separator)
			add(showVariablesToggleButton)
			add(rememberShapePositionsToggleButton)
			add(new CleanShapePositionsAction(Messages.StaticDiagram_CleanShapePositions_Description, configuration))
			add(
				new CleanAllRelashionshipsAction(Messages.StaticDiagram_CleanAllRelationships_Description,
					configuration))
			add(new ShowHiddenComponents(Messages.StaticDiagram_ShowHiddenComponents_Description, configuration))
			add(new ShowHiddenParts(Messages.StaticDiagram_ShowHiddenParts_Description, configuration))
			add(new Separator)
			add(new AddOutsiderClass(Messages.StaticDiagram_AddOutsiderClass_Description, configuration))
			add(
				new DeleteAllOutsiderClasses(Messages.StaticDiagram_DeleteAllOutsiderClasses_Description,
					configuration))
//			In a future could remain as options: "Open External wsdi" & "Save As..." 			
//			add(new LoadStaticDiagramConfigurationAction(Messages.StaticDiagram_LoadConfiguration_Description, configuration, this))
//			add(new SaveStaticDiagramConfigurationAction(Messages.StaticDiagram_SaveConfiguration_Description, configuration))
		]
	}

	override shouldRegisterContextMenu() { true }

	override getContextMenuProvider(GraphicalViewer graphicalViewer, ActionRegistry actionRegistry) {
		new StaticDiagramEditorContextMenuProvider(graphicalViewer, getActionRegistry)
	}

	override layout() {
		// create graph
		val graph = new DirectedGraph
		graph.direction = PositionConstants.SOUTH

		val parts = (classEditParts + objectsEditParts + mixinsEditParts)
		val nodes = parts.map[e|e.createNode]

		graph.edges.addAll(inheritanceConnectionsEditParts.map [ c |
			new Edge(nodes.findFirst[n|n.data == c.source.model], nodes.findFirst[n|n.data == c.target.model])
		])

		// layout
		val directedGraphLayout = new DirectedGraphLayout
		directedGraphLayout.visit(graph)
	}

	def createNode(AbstractGraphicalEditPart e) {
		new Node(e.model) => [
			width = e.figure.preferredSize.width
			height = e.figure.preferredSize.height
		]
	}

	def getClassEditParts() { getEditPartsOfType(ClassEditPart) }

	def getObjectsEditParts() { getEditPartsOfType(NamedObjectEditPart) }

	def getMixinsEditParts() { getEditPartsOfType(MixinEditPart) }

	def getInheritanceConnectionsEditParts() { getEditPartsOfType(InheritanceConnectionEditPart) }

	def getAssociationConnectionsEditParts() { getEditPartsOfType(AssociationConnectionEditPart) }

	def <T> Iterable<T> getEditPartsOfType(Class<T> t) {
		(graphicalViewer.rootEditPart.children.get(0) as EditPart).children.filter(t)
	}

	override doGetActionRegistry(ActionRegistry actionRegistry) {
		// Contextual menu for objects
		actionRegistry.registerAction(new DeleteElementAction(this, graphicalViewer, configuration))
		actionRegistry.registerAction(new ShowHiddenPartsElementAction(this, graphicalViewer, configuration))
	}

	override getAdapter(@SuppressWarnings("rawtypes") Class type) {
		if (type == PalettePage) {
			if (splitter === null) {
				page = createPalettePage
				return page
			}
			return createPalettePage
		}
		if (type == IPropertySheetPage) {
			return new UndoablePropertySheetPage(commandStack, getActionRegistry.getAction(ActionFactory.UNDO.id),
				getActionRegistry.getAction(ActionFactory.REDO.id))
		}
		if (type == GraphicalViewer)
			return graphicalViewer
		if (type == CommandStack)
			return commandStack
		if (type == ActionRegistry)
			return actionRegistry
		if (type == EditPart && graphicalViewer !== null)
			return graphicalViewer.rootEditPart
		if (type == IFigure && graphicalViewer !== null)
			return (graphicalViewer.rootEditPart as GraphicalEditPart).figure
		if (type == ZoomManager)
			return (graphicalViewer.rootEditPart as ScalableFreeformRootEditPart).zoomManager
		super.getAdapter(type)
	}

	def createPalettePage() {
		new CustomPalettePage(paletteViewerProvider, this)
	}

	override setSourceViewer(ISourceViewer sourceViewer) {
		this.sourceViewer = sourceViewer
		val document = sourceViewer.document
		updateDocument(new XtextDocumentUtil().getXtextDocument(document))
	}

	def updateDocument(IXtextDocument doc) {
		if (doc !== null) {
			if(xtextDocument !== null) xtextDocument.removeDocumentListener(this)
			xtextDocument = doc
			xtextDocument.addDocumentListener(this)
			val IResource resource = xtextDocument.getAdapter(typeof(IResource))
			configuration.resource = resource
			refresh()
		}
	}

	val refreshJob = new UIJob(Messages.StaticDiagram_UpdateDiagramView) {
		override runInUIThread(IProgressMonitor monitor) {
			diagram = createDiagramModel
			initializeGraphicalViewer
			Status.OK_STATUS
		}
	}

	def refresh() {
		refreshJob.schedule
	}

	// IDocumentListener
	override documentAboutToBeChanged(DocumentEvent event) {}

	override documentChanged(DocumentEvent event) {
		refresh
	}

	// ****************************	
	// ** Part listener (listen for open editor)
	// ****************************
	override partBroughtToTop(IWorkbenchPart part) {
		if (part instanceof XtextEditor) {
			if (part.languageName == WollokActivator.ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL)
				updateDocument(part.document)
		}
	}

	// workbench -> gef editor
	override selectionChanged(IWorkbenchPart part, ISelection selection) {
		if (part == this) return;
		if (selection instanceof StructuredSelection) {
			// I think this is coupled with the outline view. It should use WClass instead of EObjectNode
			// should we use getAdapter() ?
			val selectedClassModels = selection
				.toList
				.filter(EObjectNode)
				.filter [ EClass == WollokDslPackage.Literals.WCLASS ]
				.fold(newArrayList()) [ classModels, clazz |
					val classModel = getClassEditParts.findFirst [ editPart |
						// mm.. i don't like comparing by name :( but our diagram seems to load 
						// the xtext document (and model objects) again, so instances are different
						editPart.castedModel.getComponent.name == clazz.text.toString
					]
					if (classModel !== null) {
						classModels += classModel
					}
					classModels
				]
			if (!selectedClassModels.empty) {
				graphicalViewer.selection = new StructuredSelection(selectedClassModels)
			}
		}
	}

	// ISelectionChangedListeners:
	// listen for changes in the gef editor, publish selection using the model
	override selectionChanged(SelectionChangedEvent event) {
		val selection = event.selection
		if (!selection.empty && selection instanceof StructuredSelection) {
			val currentSelection = selection as StructuredSelection
			if (currentSelection.size == 1) {
				val model = (currentSelection.firstElement as EditPart).model
				if (model instanceof ClassModel) {
					val clazz = model.getComponent
					if (clazz !== null) {
						this.selection = new StructuredSelection(clazz) ?: selection
						val selectionChangedEvent = new SelectionChangedEvent(this, selection)
						currentListeners.forEach [ listener |
							listener.selectionChanged(selectionChangedEvent)
						]
					}
				}
			}
		}
	}

	/* Static Diagram Configuration Notifications */
	override update(Observable o, Object event) {
		if (event !== null && event.equals(StaticDiagramConfiguration.CONFIGURATION_CHANGED)) {
			this.refresh
		}
	}

	override createEditPartFactory() {
		new StaticDiagramEditPartFactory
	}

}
