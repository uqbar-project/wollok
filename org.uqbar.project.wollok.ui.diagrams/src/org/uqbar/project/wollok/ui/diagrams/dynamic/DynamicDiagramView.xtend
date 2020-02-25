package org.uqbar.project.wollok.ui.diagrams.dynamic

import java.util.ArrayList
import java.util.Collections
import java.util.List
import java.util.Map
import org.eclipse.core.runtime.Platform
import org.eclipse.core.runtime.preferences.IEclipsePreferences
import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.draw2d.ColorConstants
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.PositionConstants
import org.eclipse.draw2d.graph.DirectedGraph
import org.eclipse.draw2d.graph.DirectedGraphLayout
import org.eclipse.draw2d.graph.Edge
import org.eclipse.draw2d.graph.Node
import org.eclipse.gef.DefaultEditDomain
import org.eclipse.gef.EditPart
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.commands.CommandStack
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart
import org.eclipse.gef.editparts.ZoomManager
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.gef.ui.actions.ZoomComboContributionItem
import org.eclipse.gef.ui.actions.ZoomInAction
import org.eclipse.gef.ui.actions.ZoomOutAction
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite.FlyoutPreferences
import org.eclipse.gef.ui.palette.PaletteViewerProvider
import org.eclipse.gef.ui.parts.GraphicalViewerKeyHandler
import org.eclipse.gef.ui.parts.ScrollingGraphicalViewer
import org.eclipse.gef.ui.parts.SelectionSynchronizer
import org.eclipse.gef.ui.properties.UndoablePropertySheetPage
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.Separator
import org.eclipse.jface.commands.ActionHandler
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.viewers.ISelectionProvider
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.IPartListener
import org.eclipse.ui.ISelectionListener
import org.eclipse.ui.IViewSite
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.PartInitException
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.handlers.IHandlerService
import org.eclipse.ui.part.ViewPart
import org.eclipse.ui.views.properties.IPropertySheetPage
import org.eclipse.xtext.ui.editor.ISourceViewerAware
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ExportAction
import org.uqbar.project.wollok.ui.diagrams.classes.model.StaticDiagram
import org.uqbar.project.wollok.ui.diagrams.classes.palette.CustomPalettePage
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.CleanAction
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.RememberObjectPositionAction
import org.uqbar.project.wollok.ui.diagrams.dynamic.parts.DynamicDiagramEditPartFactory
import org.uqbar.project.wollok.ui.diagrams.dynamic.parts.ValueEditPart
import org.uqbar.project.wollok.ui.diagrams.dynamic.parts.VariableModel
import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart
import org.uqbar.project.wollok.ui.launch.Activator

/**
 * 
 * @author jfernandes
 * @author dodain - REPL integration
 */
class DynamicDiagramView extends ViewPart implements ISelectionListener, ISourceViewerAware, IPartListener, ISelectionProvider, ISelectionChangedListener, IStackFrameConsumer, XContextStateListener {
	
	DefaultEditDomain editDomain
	GraphicalViewer graphicalViewer
	SelectionSynchronizer synchronizer
	ActionRegistry actionRegistry

	StaticDiagram diagram

	IViewSite site

	// Toolbar - actions
	RememberObjectPositionAction rememberAction
	CleanAction cleanAction
	ExportAction exportAction
	IAction zoomIn
	IAction zoomOut

	// Frozen until debugger renaissance
	// DebugContextListener debugListener
	// New context state listener
	// splitter and palette
	FlyoutPaletteComposite splitter
	CustomPalettePage page
	PaletteViewerProvider provider

	List<XDebugStackFrameVariable> currentVariables = newArrayList
	
	public static Map<String, XDebugStackFrameVariable> variableValues

	new() {
		editDomain = new DefaultEditDomain(null)
//		editDomain.paletteRoot = ClassDiagramPaletterFactory.create
	}

	override init(IViewSite site) throws PartInitException {
		super.init(site)
		this.site = site

		Activator.^default.wollokDynamicDiagramContextStateNotifier.init(this)

		// listen for selection
		site.workbenchWindow.selectionService.addSelectionListener(this)
		site.workbenchWindow.activePage.addPartListener(this)
		site.selectionProvider = this
	}

	def createDiagramModel() {
		null
	}

	override createPartControl(Composite parent) {
		splitter = new FlyoutPaletteComposite(parent, SWT.NONE, site.page, paletteViewerProvider, palettePreferences);
		createViewer(splitter)

		splitter.graphicalControl = graphicalViewer.control
		if (page !== null) {
			splitter.externalViewer = page.getPaletteViewer
			page = null
		}

		// Create toolbar
		configureToolbar

		//
		// Frozen until debugger renaissance
		// debugListener = new DebugContextListener(this)
		// DebugUITools.getDebugContextManager.addDebugContextListener(debugListener)
		//
		// Check if there is an already started debug context
		// val dc = DebugUITools.getDebugContext
		// if (dc !== null) {
		// val o = dc.getAdapter(IStackFrame)
		// if (o instanceof IStackFrame)
		// setStackFrame(o as IStackFrame)
		// }
		// End Frozen until debugger renaissance
		// set initial content based on active editor (if any)
		partBroughtToTop(site.page.activeEditor)
		
		// we provide selection
		site.selectionProvider = this
	}

	def configureToolbar() {
		getActionRegistry

		rememberAction = new RememberObjectPositionAction(this)
		
		cleanAction = new CleanAction => [
			diagram = this
		]
		
		exportAction = new ExportAction => [
			viewer = graphicalViewer
		]

		site.actionBars.toolBarManager => [
			add(new ZoomComboContributionItem(site.workbenchWindow.activePage, #{
				ZoomManager.FIT_ALL,
				ZoomManager.FIT_HEIGHT,
				ZoomManager.FIT_WIDTH
			} as String[]))
			add(zoomIn)
			add(zoomOut)
			add(new Separator)
			add(rememberAction)
			add(new Separator)
			add(cleanAction)
			add(exportAction)
			add(new Separator)
		]
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

	def configureGraphicalViewer() {
		graphicalViewer.control.background = ColorConstants.listBackground

		graphicalViewer.editPartFactory = new DynamicDiagramEditPartFactory
		graphicalViewer.rootEditPart = new ScalableFreeformRootEditPart
		graphicalViewer.keyHandler = new GraphicalViewerKeyHandler(graphicalViewer)
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

	def setGraphicalViewer(GraphicalViewer viewer) {
		editDomain.addViewer(viewer)
		graphicalViewer = viewer
//		graphicalViewer.addSelectionChangedListener(this)
	}

	override setFocus() {
		graphicalViewer.control.setFocus
	}

	def getActionRegistry() {
		if (actionRegistry === null) {
			actionRegistry = new ActionRegistry => [
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
				service.activateHandler(zoomIn.getActionDefinitionId(), new	ActionHandler(zoomIn))
				service.activateHandler(zoomOut.getActionDefinitionId(), new ActionHandler(zoomOut))
			]
		}
		actionRegistry
	}

	def CommandStack getCommandStack() {
		editDomain.commandStack
	}

	override getAdapter(Class type) {
		if (type == IPropertySheetPage) {
			new UndoablePropertySheetPage(commandStack, getActionRegistry.getAction(ActionFactory.UNDO.id),
				getActionRegistry.getAction(ActionFactory.REDO.id))
		} else if (type == GraphicalViewer)
			graphicalViewer
		else if (type == CommandStack)
			commandStack
		else if (type == ActionRegistry)
			actionRegistry
		else if (type == EditPart && graphicalViewer !== null)
			graphicalViewer.rootEditPart
		else if (type == IFigure && graphicalViewer !== null)
			(graphicalViewer.rootEditPart as GraphicalEditPart).figure
		else if (type == ZoomManager)
			(graphicalViewer.rootEditPart as ScalableFreeformRootEditPart).zoomManager
		else
			super.getAdapter(type)
	}

	def createPalettePage() {
//		new CustomPalettePage(paletteViewerProvider, this);
	}

	def getSelectionSynchronizer() {
		if(synchronizer === null) synchronizer = new SelectionSynchronizer
		synchronizer
	}

	def getModel() {
		diagram
	}

	override dispose() {
		site.workbenchWindow.selectionService.removeSelectionListener(this)
		editDomain.activeTool = null
		if(actionRegistry !== null) actionRegistry.dispose

		if (Display.current !== null) super.dispose
	}

	override setSourceViewer(ISourceViewer sourceViewer) {}

	// ****************************	
	// ** Layout (same as for class diagrams... horrible)
	// ****************************
	def getNodesEditParts() { editParts(ValueEditPart) }

	def getConnectionsEditParts() { editParts(ConnectionEditPart) }

	def <T extends EditPart> editParts(Class<T> class1) {
		if (graphicalViewer.rootEditPart.children.empty)
			Collections.EMPTY_LIST
		else
			(graphicalViewer.rootEditPart.children.get(0) as EditPart).children.filter(class1)
	}

	def layout() {
		// create graph
		val graph = new DirectedGraph
		graph.direction = PositionConstants.SOUTH

		val classToNodeMapping = nodesEditParts.fold(newHashMap) [ map, e |
			map.put(e.model as VariableModel, new Node(e.model) => [
				width = 100 // e.figure.bounds.width
				height = 100 // e.figure.bounds.height
			])
			map
		]
		graph.nodes.addAll(classToNodeMapping.values)

		graph.edges.addAll(connectionsEditParts.map [ c |
			new Edge(
				classToNodeMapping.get(c.castedModel.source),
				classToNodeMapping.get(c.castedModel.target)
			)
		])

		// layout
		new DirectedGraphLayout => [
			visit(graph)
		]

	// map back positions to model
	/* 
	 * graph.nodes.forEach [
	 * 	val n = it as Node
	 * 	(n.data as Shape).location = new Point(n.x, n.y)
	 * ]
	 * 
	 */
	}

	// ****************************	
	// ** Palette
	// ****************************
	def getSplitter() { splitter }

	def getPaletteViewerProvider() {
		if(provider === null) provider = createPaletteViewerProvider
		provider
	}

	def createPaletteViewerProvider() { new PaletteViewerProvider(editDomain) }

	def getPalettePreferences() {
		val preferencesService = Platform.getPreferencesService() //as PreferenceServices 
		new WollokFlyoutPreferences(preferencesService.rootNode)
		//FlyoutPaletteComposite.createFlyoutPreferences(WollokDiagramsPlugin.getDefault.pluginPreferences)
	}

	// ****************************	
	// ** Part listener (listen for open editor)
	// ****************************
	override partActivated(IWorkbenchPart part) {}

	override partBroughtToTop(IWorkbenchPart part) {}

	override partClosed(IWorkbenchPart part) {}

	override partDeactivated(IWorkbenchPart part) {}

	override partOpened(IWorkbenchPart part) {}

	override selectionChanged(IWorkbenchPart part, ISelection selection) {}

	// SELECTION PROVIDER
	val listeners = new ArrayList<ISelectionChangedListener>
	var ISelection selection = null

	override addSelectionChangedListener(ISelectionChangedListener listener) { listeners += listener }

	override removeSelectionChangedListener(ISelectionChangedListener listener) { listeners -= listener }

	override getSelection() { selection }

	override setSelection(ISelection selection) {}

	override selectionChanged(SelectionChangedEvent event) {}

	// posta
	override setStackFrame(IStackFrame stackframe) {
		updateDynamicDiagram(stackframe)
	}

	def getEditPart() { graphicalViewer.contents }

	def getChildrenEditParts() { if(editPart !== null) editPart.children as List<ValueEditPart> else #[] }

	def getNewModels() { childrenEditParts.map[ep|ep.model as VariableModel] }

	def relocateSolitaryNodes(List<VariableModel> models) {
		/*val nodesReferencedByJustOne = models.filter[m|m.targetConnections.size == 1]
		 * nodesReferencedByJustOne.forEach [ m |
		 * 	m.moveCloseTo(m.targetConnections.get(0).source)
		 ]*/
	}

	override stateChanged(List<XDebugStackFrameVariable> variables) {
		if (splitter.disposed) {
			return
		}
		variableValues = newHashMap
		variables.forEach[ variable | variable.collectValues(variableValues) ]
		this.currentVariables = variables
			.filter [ isCustom ]
			.toList
		this.refreshView
	}

	def void updateDynamicDiagram(Object variables) {
		VariableModel.initVariableShapes

		// backup nodes positions
		/*val oldRootPart = graphicalViewer.contents as AbstractStackFrameEditPart<?>
		 * val map = new HashMap<String, Shape>()
		 * if (oldRootPart !== null) {
		 * 	oldRootPart.children.<ValueEditPart>forEach [ it |
		 * 		map.put((it.model as VariableModel).valueString, it.model as Shape)
		 * 	]
		 }*/
		// set new stack
		graphicalViewer.contents = variables

		layout()

	// recover old positions
	/*val newModels = newModels
	 * val alreadyDisplaying = newModels.filter[map.containsKey(valueString)].toList
	 * alreadyDisplaying.forEach [ vm |
	 * 	val oldShape = map.get(vm.valueString)
	 * 	vm.location = oldShape.location
	 * 	vm.size = oldShape.size
	 ]*/
	}
	
	def cleanDiagram() {
		stateChanged(newArrayList)		
	}
	
	def refreshView() {
		RunInUI.runInUI [
			updateDynamicDiagram(this.currentVariables)
		]
		
	}
	
}

class WollokFlyoutPreferences implements FlyoutPreferences {
	static final String PALETTE_DOCK_LOCATION = "org.wollok.eclipse.gef.pdock"; //$NON-NLS-1$
	static final String PALETTE_SIZE = "org.wollok.eclipse.gef.psize"; //$NON-NLS-1$
	static final String PALETTE_STATE = "org.wollok.eclipse.gef.pstate"; //$NON-NLS-1$
	IEclipsePreferences prefs
	new(IEclipsePreferences _prefs) {
		prefs = _prefs
	}
	override getDockLocation() {
		prefs.getInt(PALETTE_DOCK_LOCATION, PositionConstants.ALWAYS_LEFT);
	}
	
	override getPaletteState() {
		prefs.getInt(PALETTE_STATE, FlyoutPaletteComposite.STATE_COLLAPSED)
	}
	
	override getPaletteWidth() {
		prefs.getInt(PALETTE_SIZE, -1)
	}
	
	override setDockLocation(int location) {
		prefs.putInt(PALETTE_DOCK_LOCATION, location)
	}
	
	override setPaletteState(int state) {
		prefs.putInt(PALETTE_STATE, state)
	}
	
	override setPaletteWidth(int width) {
		prefs.putInt(PALETTE_SIZE, width)
	}
	
}
