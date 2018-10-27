package org.uqbar.project.wollok.ui.diagrams.objects

import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.List
import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.debug.ui.DebugUITools
import org.eclipse.draw2d.ColorConstants
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.PositionConstants
import org.eclipse.draw2d.geometry.Point
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
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite
import org.eclipse.gef.ui.palette.PaletteViewerProvider
import org.eclipse.gef.ui.parts.GraphicalViewerKeyHandler
import org.eclipse.gef.ui.parts.ScrollingGraphicalViewer
import org.eclipse.gef.ui.parts.SelectionSynchronizer
import org.eclipse.gef.ui.properties.UndoablePropertySheetPage
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.ISelectionChangedListener
import org.eclipse.jface.viewers.ISelectionProvider
import org.eclipse.jface.viewers.SelectionChangedEvent
import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IPartListener
import org.eclipse.ui.ISelectionListener
import org.eclipse.ui.IViewSite
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.PartInitException
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.part.ViewPart
import org.eclipse.ui.views.properties.IPropertySheetPage
import org.eclipse.xtext.ui.editor.ISourceViewerAware
import org.uqbar.project.wollok.WollokActivator
import org.uqbar.project.wollok.interpreter.IWollokInterpreterListener
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.ui.diagrams.classes.WollokDiagramsPlugin
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.model.StaticDiagram
import org.uqbar.project.wollok.ui.diagrams.classes.palette.CustomPalettePage
import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart
import org.uqbar.project.wollok.ui.diagrams.objects.parts.ObjectDiagramEditPartFactory
import org.uqbar.project.wollok.ui.diagrams.objects.parts.StackFrameEditPart
import org.uqbar.project.wollok.ui.diagrams.objects.parts.ValueEditPart
import org.uqbar.project.wollok.ui.diagrams.objects.parts.VariableModel
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * 
 * @author jfernandes
 */
class ObjectDiagramView extends ViewPart implements ISelectionListener, ISourceViewerAware, IPartListener, ISelectionProvider, ISelectionChangedListener, IStackFrameConsumer, IWollokInterpreterListener {
	DefaultEditDomain editDomain
	GraphicalViewer graphicalViewer
	SelectionSynchronizer synchronizer
	ActionRegistry actionRegistry
	
	StaticDiagram diagram
	
	DebugContextListener debugListener
	
	// splitter and palette
	FlyoutPaletteComposite splitter
	CustomPalettePage page
	PaletteViewerProvider provider
	
	new() {
		editDomain = new DefaultEditDomain(null)
//		editDomain.paletteRoot = ClassDiagramPaletterFactory.create
	}
	
	override init(IViewSite site) throws PartInitException {
		super.init(site)
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
		
		debugListener = new DebugContextListener(this)
		DebugUITools.getDebugContextManager.addDebugContextListener(debugListener)
		WollokActivator.addReplListener(this)

		// Check if there is an already started debug context
		val dc = DebugUITools.getDebugContext
		if (dc !== null) {
			val o = dc.getAdapter(IStackFrame)
			if (o instanceof IStackFrame)
				setStackFrame(o as IStackFrame)
		}
		
		// set initial content based on active editor (if any)
		partBroughtToTop(site.page.activeEditor)
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

		graphicalViewer.editPartFactory = new ObjectDiagramEditPartFactory
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
		if (actionRegistry === null) actionRegistry = new ActionRegistry
		actionRegistry
	}
	def CommandStack getCommandStack() {
		editDomain.commandStack
	}
	
	override getAdapter(Class type) {
		if (type == IPropertySheetPage) {
			new UndoablePropertySheetPage(commandStack,
					getActionRegistry.getAction(ActionFactory.UNDO.id),
					getActionRegistry.getAction(ActionFactory.REDO.id))
		}
		else if (type == GraphicalViewer) graphicalViewer
		else if (type == CommandStack) commandStack
		else if (type == ActionRegistry) actionRegistry
		else if (type == EditPart && graphicalViewer !== null) graphicalViewer.rootEditPart
		else if (type == IFigure && graphicalViewer !== null) (graphicalViewer.rootEditPart as GraphicalEditPart).figure
		else super.getAdapter(type)
	}
	
	def createPalettePage() {
//		new CustomPalettePage(paletteViewerProvider, this);
	}
	
	def getSelectionSynchronizer() {
		if (synchronizer === null) synchronizer = new SelectionSynchronizer
		synchronizer
	}
	
	def getModel() {
		diagram
	}
	
	override dispose() {
		site.workbenchWindow.selectionService.removeSelectionListener(this)
		editDomain.activeTool = null
		if (actionRegistry !== null) actionRegistry.dispose
		
		super.dispose
	}
	
	override setSourceViewer(ISourceViewer sourceViewer) { }
	
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
		
		val classToNodeMapping = nodesEditParts.fold(newHashMap)[map, e | 
			map.put(e.model as VariableModel, new Node(e.model) => [
				width = 100 //e.figure.bounds.width
				height = 100 //e.figure.bounds.height
			])
			map
		]
		graph.nodes.addAll(classToNodeMapping.values)
		
		graph.edges.addAll(connectionsEditParts.map[c |
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
		graph.nodes.forEach[ val n = it as Node
			(n.data as Shape).location = new Point(n.x, n.y)
		]
	} 
	
	
	// ****************************	
	// ** Palette
	// ****************************
	
	def getSplitter() { splitter }
	def getPaletteViewerProvider() {
		if (provider === null) provider = createPaletteViewerProvider
		provider
	}
	def createPaletteViewerProvider() { new PaletteViewerProvider(editDomain) }
	def getPalettePreferences() { FlyoutPaletteComposite.createFlyoutPreferences(WollokDiagramsPlugin.getDefault.pluginPreferences) }

	// ****************************	
	// ** Part listener (listen for open editor)
	// ****************************
	
	override partActivated(IWorkbenchPart part) { }
	override partBroughtToTop(IWorkbenchPart part) { }
	override partClosed(IWorkbenchPart part) { }
	override partDeactivated(IWorkbenchPart part) { }
	override partOpened(IWorkbenchPart part) { }
	override selectionChanged(IWorkbenchPart part, ISelection selection) {}

	// SELECTION PROVIDER
	val listeners = new ArrayList<ISelectionChangedListener>
	var ISelection selection = null
	
	override addSelectionChangedListener(ISelectionChangedListener listener) { listeners += listener }
	override removeSelectionChangedListener(ISelectionChangedListener listener) { listeners -= listener }
	override getSelection() { selection }
	override setSelection(ISelection selection) { }
	override selectionChanged(SelectionChangedEvent event) { }
	
	// posta
	
	override setStackFrame(IStackFrame stackframe) {
		// backup nodes positions
		val oldRootPart = graphicalViewer.contents as StackFrameEditPart
		val map = new HashMap<String,Shape>()
		if (oldRootPart !== null) {
			oldRootPart.children.<ValueEditPart>forEach[it |
				map.put((it.model as VariableModel).valueString, it.model as Shape)
			]
		}
		
		// set new stack
		graphicalViewer.contents = stackframe
		
		layout()
		
		// recover old positions
		val newModels = newModels
		val alreadyDisplaying = newModels.filter[ map.containsKey(valueString) ].toList
		alreadyDisplaying.forEach[vm |
				val oldShape = map.get(vm.valueString)
				vm.location = oldShape.location
				vm.size = oldShape.size
		]
		
		// tweak layout
//		val newNodes = newModels.filter[!alreadyDisplaying.contains(it)].toList
//		relocateSolitaryNodes(newNodes)
	}
	
	def getEditPart() { graphicalViewer.contents as StackFrameEditPart }
	def getChildrenEditParts() { if (editPart !== null) editPart.children as List<ValueEditPart> else #[]}
	def getNewModels() { childrenEditParts.map[ ep | ep.model as VariableModel ] }
	
	def relocateSolitaryNodes(List<VariableModel> models) {
		val nodesReferencedByJustOne = models.filter[m | m.targetConnections.size == 1]
		nodesReferencedByJustOne.forEach[m | 
			m.moveCloseTo(m.targetConnections.get(0).source)
		]
	}
	
	override messageSent(WollokInterpreter interpreter, WFile parsedFile) {
		println("je, mirá lo que me vino " + interpreter)
	}
	
}