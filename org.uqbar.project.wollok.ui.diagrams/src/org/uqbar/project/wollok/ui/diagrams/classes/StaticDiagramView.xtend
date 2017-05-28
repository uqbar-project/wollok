package org.uqbar.project.wollok.ui.diagrams.classes

import com.google.inject.Inject
import java.util.ArrayList
import java.util.Comparator
import java.util.HashMap
import java.util.List
import java.util.Observable
import java.util.Observer
import java.util.Set
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
import org.eclipse.emf.ecore.EObject
import org.eclipse.gef.DefaultEditDomain
import org.eclipse.gef.EditPart
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.commands.CommandStack
import org.eclipse.gef.editparts.AbstractGraphicalEditPart
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite
import org.eclipse.gef.ui.palette.PaletteViewerProvider
import org.eclipse.gef.ui.parts.GraphicalViewerKeyHandler
import org.eclipse.gef.ui.parts.ScrollingGraphicalViewer
import org.eclipse.gef.ui.parts.SelectionSynchronizer
import org.eclipse.gef.ui.properties.UndoablePropertySheetPage
import org.eclipse.gef.ui.views.palette.PalettePage
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
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.ISourceViewerAware
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.XtextDocumentUtil
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.CleanAllRelashionshipsAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.CleanShapePositionsAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.DeleteAssociationAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ExportAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.HideComponentAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.RememberShapePositionsToggleButton
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowFileAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowHiddenComponents
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowVariablesToggleButton
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.MixinModel
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
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamed
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author jfernandes
 */
class StaticDiagramView extends ViewPart implements ISelectionListener, ISourceViewerAware, IPartListener, ISelectionProvider, ISelectionChangedListener, IDocumentListener, Observer {
	DefaultEditDomain editDomain
	GraphicalViewer graphicalViewer
	SelectionSynchronizer synchronizer
	ActionRegistry actionRegistry
	
	IXtextDocument xtextDocument
	
	//@Inject
	//XtextResourceSet resourceSet
	
	StaticDiagram diagram
	
	// splitter and palette
	FlyoutPaletteComposite splitter
	CustomPalettePage page
	PaletteViewerProvider provider

	ExportAction exportAction

	StaticDiagramConfiguration configuration
		
	new() {
		editDomain = new DefaultEditDomain(null)
		editDomain.paletteRoot = StaticDiagramPaletterFactory.create
		configuration = new StaticDiagramConfiguration
		configuration.addObserver(this)
		Shape.useConfiguration(configuration)
	}
	
	override init(IViewSite site) throws PartInitException {
		super.init(site)
		// listen for selection
		site.workbenchWindow.selectionService.addSelectionListener(this)
		site.workbenchWindow.activePage.addPartListener(this)
		
		exportAction = new ExportAction
		val showVariablesToggleButton = new ShowVariablesToggleButton(Messages.StaticDiagram_Show_Variables, configuration)
		val rememberShapePositionsToggleButton = new RememberShapePositionsToggleButton(Messages.StaticDiagram_RememberShapePositions_Description, configuration)
		
		site.actionBars.toolBarManager => [
			add(new ShowFileAction("labelFile", configuration))
			add(new Separator)
			add(exportAction)
			add(new Separator)
			add(showVariablesToggleButton)
			add(rememberShapePositionsToggleButton)
			add(new CleanShapePositionsAction(Messages.StaticDiagram_CleanShapePositions_Description, configuration))
			add(new CleanAllRelashionshipsAction(Messages.StaticDiagram_CleanAllRelationships_Description, configuration))
			add(new ShowHiddenComponents(Messages.StaticDiagram_ShowHiddenComponents_Description, configuration))
//			In a future could remain as options: "Open External wsdi" & "Save As..." 			
//			add(new LoadStaticDiagramConfigurationAction(Messages.StaticDiagram_LoadConfiguration_Description, configuration, this))
//			add(new SaveStaticDiagramConfigurationAction(Messages.StaticDiagram_SaveConfiguration_Description, configuration))
		]
	}
	
	def createDiagramModel() {
		NamedObjectModel.init()
		MixinModel.init()
		new StaticDiagram(configuration) => [
			// all objects
			val objects = xtextDocument.readOnly[ namedObjects ]
			
			// class
			val classes = xtextDocument.readOnly[ classes ].toSet
			val importedClasses = xtextDocument.readOnly [ getImportedClasses ].toSet
			importedObjects = importedClasses.toList
			classes.addAll(importedClasses)
			classes.addAll(classes.clone.map[c| c.superClassesIncludingYourself].flatten)
			val List<WMethodContainer> allClasses = classes.removeDuplicated as List<WMethodContainer>
			val List<WMethodContainer> inheritingObjects = objects.filter [ hasRealParent ].toList.clone
			var List<WMethodContainer> allClassModelAbstractions = newArrayList => [
				addAll(allClasses.clone)
				addAll(inheritingObjects)
			]
			ClassModel.init(allClassModelAbstractions)
			
			// objects (first so that we collect parents in the "classes" set
			val singleObjects = objects.filter [ !hasRealParent && !configuration.isHiddenComponent(name) ]
			
			singleObjects.forEach[ o | 
				addNamedObject(new NamedObjectModel(o) => [ 
					locate
				])
			]

			// classes
			// first, superclasses
			var classesCopy = allClassModelAbstractions
				.clone
				.filter [ it.parent === null ]
				.toList
				
			var int level = 0
			while (!classesCopy.isEmpty) {
				val levelCopy = level
				classesCopy.forEach [ c | addComponent(c, levelCopy) ]
				val parentClasses = classesCopy
				// then subclasses of parent classes and recursively...
				classesCopy = allClassModelAbstractions
					.clone
					.filter [
						parentClasses.contains(it.parent)
					]
					.sortWith([ WMethodContainer a, WMethodContainer b |
						val orderForA = (a.parent?.name ?: "") + a.name
						val orderForB = (b.parent?.name ?: "") + b.name
						orderForA.compareTo(orderForB)
					] as Comparator<WMethodContainer>)
					.toList
					
				level++
			}

			// mixins (for classes and objects)
			val mixins = xtextDocument.readOnly[ mixins ].toSet
			mixins.addAll((allClasses + objects).map [ o | o.mixins ].flatten.toSet)
			var allMixins = mixins.removeDuplicated as List<WMixin>
			allMixins = allMixins.filter [!configuration.isHiddenComponent(name)].toList
			allMixins.forEach [ m | addMixin(m) ]

			// relations
			connectInheritanceRelations
			connectAssociationRelations
		]
	}
	
	def getParentClass(WClass wclass) {
		if (wclass.parent == null) {
			return ""
		}
		wclass.parent.name
	}
	
	def getMixins(XtextResource it) { getAllOfType(WMixin) }
	def getClasses(XtextResource it) { getAllOfType(WClass) }
	def getNamedObjects(XtextResource it) { getAllOfType(WNamedObject) }
	
	def <T extends EObject> Iterable<T> getAllOfType(XtextResource it, Class<T> type) {
		if (contents.empty) #[]
		else (contents.get(0) as WFile).eAllContents.filter(type).toList
	}
	
	
	@Inject WollokClassFinder finder
	
	def getImportedClasses(XtextResource it) {
		val imports = getAllOfType(Import)
		imports.fold(newArrayList)[l, i |
			try {
				l.add(finder.getCachedClass(i, i.importedNamespace))
			}
			catch(ClassCastException e) {
				// Temporarily user is writing another import
			}
			catch(WollokRuntimeException e) { }
			l
		]
	}
	
	override createPartControl(Composite parent) {
		splitter = new FlyoutPaletteComposite(parent, SWT.NONE, site.page, paletteViewerProvider, palettePreferences)
		createViewer(splitter)
		
		splitter.graphicalControl = graphicalViewer.control
		if (page != null) {
			splitter.externalViewer = page.getPaletteViewer
			page = null
		}
		
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
		exportAction.viewer = graphicalViewer
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
		if (model != null) {
			graphicalViewer.contents = model
			layout
		}
	}
	
	def layout() {
		// create graph
		val graph = new DirectedGraph
		graph.direction = PositionConstants.SOUTH
		
		val parts = (classEditParts + objectsEditParts + mixinsEditParts)
		val nodes = parts.map[e | e.createNode ]
		
		graph.edges.addAll(inheritanceConnectionsEditParts.map[c| 
			new Edge(nodes.findFirst[n| n.data == c.source.model], nodes.findFirst[n| n.data == c.target.model])
		])
		
		// layout
		val directedGraphLayout = new DirectedGraphLayout
		directedGraphLayout.visit(graph)
		
		// map back positions to model inverting the Y coordinates
		// because the directed graph only supports layout directo to SOUTH, meaning
		// super classes will be at the bottom. So we invert them
		/*
		val bottomNode = if (graph.nodes.empty) null else graph.nodes.maxBy[ (it as Node).y ] as Node

		graph.nodes.forEach[ val n = it as Node
			var deltaY = 10
			if (n != bottomNode) deltaY += bottomNode.height;
			(n.data as Shape).location = new Point(n.x, bottomNode.y - n.y + deltaY)
		]
		*/
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
		if (actionRegistry == null) actionRegistry = new ActionRegistry => [
			registerAction(new DeleteAssociationAction(this, graphicalViewer, configuration))
			registerAction(new HideComponentAction(this, graphicalViewer, configuration))
		]
		actionRegistry
	}
	
	def CommandStack getCommandStack() {
		editDomain.commandStack
	}
	
	override getAdapter(Class type) {
		if (type == PalettePage) {
			if (splitter == null) {
				page = createPalettePage
				return page
			}
			return createPalettePage
		}
		if (type == IPropertySheetPage) {
			return new UndoablePropertySheetPage(commandStack,
					getActionRegistry.getAction(ActionFactory.UNDO.id),
					getActionRegistry.getAction(ActionFactory.REDO.id))
		}
		if (type == GraphicalViewer)
			return graphicalViewer
		if (type == CommandStack)
			return commandStack
		if (type == ActionRegistry)
			return actionRegistry
		if (type == EditPart && graphicalViewer != null)
			return graphicalViewer.rootEditPart
		if (type == IFigure && graphicalViewer != null)
			return (graphicalViewer.rootEditPart as GraphicalEditPart).figure
		super.getAdapter(type)
	}
	
	def createPalettePage() {
		new CustomPalettePage(paletteViewerProvider, this);
	}
	
	def getSelectionSynchronizer() {
		if (synchronizer == null)
			synchronizer = new SelectionSynchronizer
		synchronizer
	}
	
	def getModel() {
		diagram
	}
	
	override dispose() {
		site.workbenchWindow.selectionService.removeSelectionListener(this)
		editDomain.activeTool = null
		if (actionRegistry != null) actionRegistry.dispose
		
		super.dispose
	}
	
	override setSourceViewer(ISourceViewer sourceViewer) {
		this.sourceViewer = sourceViewer
		val document = sourceViewer.document
		updateDocument(XtextDocumentUtil.get(document))
	}
	
	def updateDocument(IXtextDocument doc) {
		if (doc != null) {
			if (xtextDocument != null) xtextDocument.removeDocumentListener(this)
			xtextDocument = doc
			xtextDocument.addDocumentListener(this)
			val IResource resource = xtextDocument.getAdapter(typeof(IResource))
			configuration.resource = resource 
			refresh()
		}
	}
	val refreshJob = new UIJob("Updating diagram view") {
			override def runInUIThread(IProgressMonitor monitor) {
				diagram = createDiagramModel
				initializeGraphicalViewer
				Status.OK_STATUS
			}
		}
	
	def refresh() {
		refreshJob.schedule
	}
	
	// IDocumentListener
	
	override documentAboutToBeChanged(DocumentEvent event) { }
	override documentChanged(DocumentEvent event) { 
		refresh
	}
	
	// ****************************	
	// ** Palette
	// ****************************
	
	def getSplitter() { splitter }
	def getPaletteViewerProvider() {
		if (provider == null)
			provider = createPaletteViewerProvider
		provider
	}
	def createPaletteViewerProvider() { new PaletteViewerProvider(editDomain) }
	def getPalettePreferences() {
		FlyoutPaletteComposite.createFlyoutPreferences(WollokDiagramsPlugin.getDefault.pluginPreferences)
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
	
	override partClosed(IWorkbenchPart part) {	}
	override partDeactivated(IWorkbenchPart part) { }
	override partOpened(IWorkbenchPart part) { }
	
	// workbench -> gef editor
	override selectionChanged(IWorkbenchPart part, ISelection selection) {
		if (part == this) return;
		if (selection instanceof StructuredSelection) {
			// I think this is coupled with the outline view. It should use WClass instead of EObjectNode
			// should we use getAdapter() ?
			val selectedClassModels = selection.toList.filter(EObjectNode).filter[EClass == WollokDslPackage.Literals.WCLASS].fold(newArrayList())[list, c|
				val cm = getClassEditParts.findFirst[ep |
					// mm.. i don't like comparing by name :( but our diagram seems to load 
					// the xtext document (and model objects) again, so instances are different
					ep.castedModel.getComponent.name == c.text.toString 
				]
				if (cm != null)
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
	//   listen for changes in the gef editor, publish selection using the model
	
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
					listeners.forEach[l| 
						l.selectionChanged(e)
					]
				}
			}
		}
	}
	
	def List<? extends WNamed> removeDuplicated(Set<? extends WNamed> wnames) {
		val namedMap = new HashMap<String, WNamed>()
		wnames.forEach [ wname |
			namedMap.put(wname.name, wname)
		]
		namedMap.values.toList
	}
	
	/* Static Diagram Configuration Notifications */
	override update(Observable o, Object event) {
		if (event?.equals(StaticDiagramConfiguration.CONFIGURATION_CHANGED)) {
			this.refresh
		}
	}

}