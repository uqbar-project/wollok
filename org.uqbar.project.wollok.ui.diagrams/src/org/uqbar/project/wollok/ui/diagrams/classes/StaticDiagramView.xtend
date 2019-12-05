package org.uqbar.project.wollok.ui.diagrams.classes

import java.util.ArrayList
import java.util.Comparator
import java.util.List
import java.util.Map
import java.util.Observable
import java.util.Observer
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.draw2d.ColorConstants
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
import org.eclipse.gef.ui.actions.ZoomInAction
import org.eclipse.gef.ui.actions.ZoomOutAction
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite
import org.eclipse.gef.ui.palette.PaletteViewerProvider
import org.eclipse.gef.ui.parts.GraphicalViewerKeyHandler
import org.eclipse.gef.ui.parts.ScrollingGraphicalViewer
import org.eclipse.gef.ui.parts.SelectionSynchronizer
import org.eclipse.gef.ui.properties.UndoablePropertySheetPage
import org.eclipse.gef.ui.views.palette.PalettePage
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.Separator
import org.eclipse.jface.text.DocumentEvent
import org.eclipse.jface.text.IDocumentListener
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.viewers.ISelectionProvider
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IPartListener
import org.eclipse.ui.ISelectionListener
import org.eclipse.ui.IViewSite
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.PartInitException
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.part.ViewPart
import org.eclipse.ui.progress.UIJob
import org.eclipse.ui.views.properties.IPropertySheetPage
import org.eclipse.xtext.ui.editor.ISourceViewerAware
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.XtextDocumentUtil
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode
import org.uqbar.project.wollok.ui.WollokActivator
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
import org.eclipse.ui.handlers.IHandlerService
import org.eclipse.jface.commands.ActionHandler
import org.uqbar.project.wollok.ui.diagrams.dynamic.WollokFlyoutPreferences
import org.eclipse.core.runtime.Platform

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
class StaticDiagramView extends ViewPart implements ISelectionListener, ISourceViewerAware, IPartListener, ISelectionProvider, ISelectionChangedListener, IDocumentListener, Observer {
	DefaultEditDomain editDomain
	GraphicalViewer graphicalViewer
	SelectionSynchronizer synchronizer
	IXtextDocument xtextDocument
	StaticDiagram diagram
	IViewSite site

	// splitter and palette
	FlyoutPaletteComposite splitter
	CustomPalettePage page
	PaletteViewerProvider provider

	ActionRegistry actionRegistry

	// Toolbar - actions
	ExportAction exportAction
	IAction zoomIn
	IAction zoomOut

	// Static diagram state and configuration
	StaticDiagramConfiguration configuration

	// @Inject WollokClassFinder finder
	new() {
		editDomain = new DefaultEditDomain(null)
		editDomain.paletteRoot = StaticDiagramPaletterFactory.create
		configuration = new StaticDiagramConfiguration
		configuration.addObserver(this)
		Shape.useConfiguration(configuration)
	}

	override init(IViewSite site) throws PartInitException {
		super.init(site)
		this.site = site
		// listen for selection
		site.workbenchWindow.selectionService.addSelectionListener(this)
		site.workbenchWindow.activePage.addPartListener(this)
	}

	def getAction(String actionId) {
		actionRegistry.getAction(actionId)
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

	override createPartControl(Composite parent) {
		splitter = new FlyoutPaletteComposite(parent, SWT.NONE, site.page, paletteViewerProvider, palettePreferences)
		createViewer(splitter)

		splitter.graphicalControl = graphicalViewer.control
		if (page !== null) {
			splitter.externalViewer = page.getPaletteViewer
			page = null
		}

		// Create toolbar		
		configureToolbar

		// set initial content based on active editor (if any)
		partBroughtToTop(site.page.activeEditor)

		// we provide selection
		site.selectionProvider = this
	}

	def createViewer(Composite parent) {
		val viewer = new ScrollingGraphicalViewer
		viewer.createControl(parent)

		setGraphicalViewer(viewer)

		configureGraphicalViewer
		hookGraphicalViewer
		initializeGraphicalViewer

		// provides selection
		site.selectionProvider = graphicalViewer
	}

	def configureToolbar() {
		exportAction = new ExportAction => [
			viewer = graphicalViewer
		]
		val showVariablesToggleButton = new ShowVariablesToggleButton(Messages.StaticDiagram_Show_Variables,
			configuration)
		val rememberShapePositionsToggleButton = new RememberShapePositionsToggleButton(
			Messages.StaticDiagram_RememberShapePositions_Description, configuration)

		site.actionBars.toolBarManager => [
			add(new ZoomComboContributionItem(site.workbenchWindow.activePage, #{
				ZoomManager.FIT_ALL,
				ZoomManager.FIT_HEIGHT,
				ZoomManager.FIT_WIDTH
			} as String[]))
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

	def configureGraphicalViewer() {
		graphicalViewer.control.background = ColorConstants.listBackground

		graphicalViewer.editPartFactory = new StaticDiagramEditPartFactory
		graphicalViewer.rootEditPart = new ScalableFreeformRootEditPart
		graphicalViewer.keyHandler = new GraphicalViewerKeyHandler(graphicalViewer)

		// configure the context menu provider
		val cmProvider = new StaticDiagramEditorContextMenuProvider(graphicalViewer, getActionRegistry)
		graphicalViewer.contextMenu = cmProvider
		site.registerContextMenu(cmProvider, graphicalViewer)
	}

	def hookGraphicalViewer() {
		selectionSynchronizer.addViewer(graphicalViewer)
		site.selectionProvider = graphicalViewer
	}

	def initializeGraphicalViewer() {
		if (model !== null) {
			graphicalViewer.contents = model
			layout
		}
	}

	def layout() {
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

	def setGraphicalViewer(GraphicalViewer viewer) {
		editDomain.addViewer(viewer)
		graphicalViewer = viewer
		graphicalViewer => [
			addSelectionChangedListener(this)
		]
	}

	override setFocus() {
		graphicalViewer.control.setFocus
	}

	def getActionRegistry() {
		if (actionRegistry === null)
			actionRegistry = new ActionRegistry => [
				registerAction(new DeleteElementAction(this, graphicalViewer, configuration))
				registerAction(new ShowHiddenPartsElementAction(this, graphicalViewer, configuration))
				// Adding zoom capabilities
				val zoomManager = (graphicalViewer.rootEditPart as ScalableFreeformRootEditPart).zoomManager
				zoomManager.setZoomLevelContributions(#[
					ZoomManager.FIT_ALL,
					ZoomManager.FIT_WIDTH,
					ZoomManager.FIT_HEIGHT
				])
				zoomIn = new ZoomInAction(zoomManager)
				zoomOut = new ZoomOutAction(zoomManager)
				registerAction(zoomIn)
				registerAction(zoomOut)

				val service = site.getService(IHandlerService)
				service.activateHandler(zoomIn.getActionDefinitionId(), new ActionHandler(zoomIn))
				service.activateHandler(zoomOut.getActionDefinitionId(), new ActionHandler(zoomOut))

			]
		actionRegistry
	}

	def CommandStack getCommandStack() {
		editDomain.commandStack
	}

	override getAdapter(Class type) {
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
		new CustomPalettePage(paletteViewerProvider, this);
	}

	def getSelectionSynchronizer() {
		if (synchronizer === null)
			synchronizer = new SelectionSynchronizer
		synchronizer
	}

	def getModel() {
		diagram
	}

	override dispose() {
		site.workbenchWindow.selectionService.removeSelectionListener(this)
		editDomain.activeTool = null
		if(actionRegistry !== null) actionRegistry.dispose

		super.dispose
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
	// ** Palette
	// ****************************
	def getSplitter() { splitter }

	def getPaletteViewerProvider() {
		if (provider === null)
			provider = createPaletteViewerProvider
		provider
	}

	def createPaletteViewerProvider() { new PaletteViewerProvider(editDomain) }

	def getPalettePreferences() {
		val preferencesService = Platform.getPreferencesService() // as PreferenceServices 
		new WollokFlyoutPreferences(preferencesService.rootNode)
		//FlyoutPaletteComposite.createFlyoutPreferences(WollokDiagramsPlugin.getDefault.pluginPreferences)
	}

	// ****************************	
	// ** Part listener (listen for open editor)
	// ****************************
	override partActivated(IWorkbenchPart part) {}

	override partBroughtToTop(IWorkbenchPart part) {
		if (part instanceof XtextEditor) {
			if (part.languageName == WollokActivator.ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL)
				updateDocument(part.document)
		}
	}

	override partClosed(IWorkbenchPart part) {}

	override partDeactivated(IWorkbenchPart part) {}

	override partOpened(IWorkbenchPart part) {}

	// workbench -> gef editor
	override selectionChanged(IWorkbenchPart part, ISelection selection) {
		if(part == this) return;
		if (selection instanceof StructuredSelection) {
			// I think this is coupled with the outline view. It should use WClass instead of EObjectNode
			// should we use getAdapter() ?
			val selectedClassModels = selection.toList.filter(EObjectNode).filter [
				EClass == WollokDslPackage.Literals.WCLASS
			].fold(newArrayList()) [ list, c |
				val cm = getClassEditParts.findFirst [ ep |
					// mm.. i don't like comparing by name :( but our diagram seems to load 
					// the xtext document (and model objects) again, so instances are different
					ep.castedModel.getComponent.name == c.text.toString
				]
				if (cm !== null)
					list += cm
				list
			]
			if (!selectedClassModels.empty) {
				graphicalViewer.selection = new StructuredSelection(selectedClassModels)
			}
		}
	}

	// SELECTION PROVIDER
	val listeners = new ArrayList<ISelectionChangedListener>
	var ISelection selection = null

	override addSelectionChangedListener(ISelectionChangedListener listener) { listeners += listener }

	override getSelection() { selection }

	override setSelection(ISelection selection) {}

	override removeSelectionChangedListener(ISelectionChangedListener listener) { listeners -= listener }

	// ISelectionChangedListeners:
	// listen for changes in the gef editor, publish selection using the model
	override selectionChanged(SelectionChangedEvent event) {
		val selection = event.selection
		if (!selection.empty && selection instanceof StructuredSelection) {
			val s = selection as StructuredSelection
			if (s.size == 1) {
				val model = (s.firstElement as EditPart).model
				if (model instanceof ClassModel) {
					val wclazz = model.getComponent
					this.selection = new StructuredSelection(wclazz)
					val e = new SelectionChangedEvent(this, this.selection)
					listeners.forEach [ l |
						l.selectionChanged(e)
					]
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

}
