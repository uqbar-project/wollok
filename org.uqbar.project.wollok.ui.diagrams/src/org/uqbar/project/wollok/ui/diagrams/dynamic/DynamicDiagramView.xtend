package org.uqbar.project.wollok.ui.diagrams.dynamic

import java.util.Collections
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.core.runtime.preferences.IEclipsePreferences
import org.eclipse.debug.core.model.IStackFrame
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
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite.FlyoutPreferences
import org.eclipse.gef.ui.properties.UndoablePropertySheetPage
import org.eclipse.jface.action.Separator
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.IViewSite
import org.eclipse.ui.PartInitException
import org.eclipse.ui.actions.ActionFactory
import org.eclipse.ui.views.properties.IPropertySheetPage
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.diagrams.AbstractDiagramView
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ExportAction
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.ColorBlindAction
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.DeleteObjectAction
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.DynamicDiagramEditorContextMenuProvider
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.EffectTransitionAction
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.FilteredObjectsAction
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.RememberObjectPositionAction
import org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar.ShowHiddenObjectsAction
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration
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
class DynamicDiagramView extends AbstractDiagramView implements IStackFrameConsumer, XContextStateListener {
	
	// Toolbar - actions
	RememberObjectPositionAction rememberAction
	FilteredObjectsAction filteredObjectsAction
	ShowHiddenObjectsAction showHiddenObjectsAction
	EffectTransitionAction effectTransitionAction
	ColorBlindAction colorBlindAction
	ExportAction exportAction

	// Frozen until debugger renaissance
	// DebugContextListener debugListener
	// New context state listener
	// splitter and palette

	DynamicDiagramConfiguration configuration = DynamicDiagramConfiguration.instance

	public static List<XDebugStackFrameVariable> currentVariables = newArrayList
	public static Map<String, XDebugStackFrameVariable> variableValues = newHashMap
	public static Map<String, XDebugStackFrameVariable> oldVariableValues = newHashMap

	new() {
		editDomain = new DefaultEditDomain(null)
	}

	override init(IViewSite site) throws PartInitException {
		super.init(site)
		Activator.^default.wollokDynamicDiagramContextStateNotifier.init(this)
		site.selectionProvider = this
	}

	def createDiagramModel() {
		null
	}

	override createPartControl(Composite parent) {
		super.createPartControl(parent)
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
	}

	override configureToolbar() {
		getActionRegistry

		colorBlindAction = new ColorBlindAction(this)
		rememberAction = new RememberObjectPositionAction(this)
		filteredObjectsAction = new FilteredObjectsAction(configuration)
		showHiddenObjectsAction = new ShowHiddenObjectsAction(this)
		effectTransitionAction = new EffectTransitionAction(this)
		exportAction = new ExportAction => [
			viewer = graphicalViewer
		]

		site.actionBars.toolBarManager => [
//			add(new ZoomComboContributionItem(site.workbenchWindow.activePage, #{
//				ZoomManager.FIT_ALL,
//				ZoomManager.FIT_HEIGHT,
//				ZoomManager.FIT_WIDTH
//			} as String[]))
			add(zoomIn)
			add(zoomOut)
			add(colorBlindAction)
			add(new Separator)
			add(rememberAction)
			add(new Separator)
			add(filteredObjectsAction)			
			add(showHiddenObjectsAction)
			add(new Separator)
			add(effectTransitionAction)
			add(exportAction)
			add(new Separator)
		]
	}

	override getContextMenuProvider(GraphicalViewer graphicalViewer, ActionRegistry actionRegistry) {
		new DynamicDiagramEditorContextMenuProvider(graphicalViewer, getActionRegistry)
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

	override layout() {
		// create graph
		val graph = new DirectedGraph
		graph.direction = PositionConstants.SOUTH

		val classToNodeMapping = nodesEditParts.fold(newHashMap) [ map, e |
			map.put(e.model as VariableModel, new Node(e.model) => [
				width = 100
				height = 100
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
	}

	override setStackFrame(IStackFrame stackframe) {
		updateDynamicDiagram(stackframe)
	}

	def getEditPart() { graphicalViewer.contents }

	def getChildrenEditParts() { if(editPart !== null) editPart.children as List<ValueEditPart> else #[] }

	def getNewModels() { childrenEditParts.map[ep|ep.model as VariableModel] }

	override stateChanged(List<XDebugStackFrameVariable> variables) {
		if (splitter.disposed) {
			return
		}
		oldVariableValues = new HashMap(variableValues)
		variableValues = newHashMap
		variables.forEach [ variable | variable.collectValues(variableValues) ]
		currentVariables = variables
			.filter [ isCustom ]
			.toList
		this.refreshView
	}

	def void updateDynamicDiagram(Object variables) {
		VariableModel.initVariableShapes

		// set new stack
		graphicalViewer.contents = variables
		layout()
	}
	
	def cleanDiagram() {
		stateChanged(newArrayList)		
	}
	
	def refreshView() {
		this.refreshView(true)
	}
	
	def refreshView(boolean withEffectTransition) {
		RunInUI.runInUI [
			if (withEffectTransition) {
				configuration.firstTimeRefreshView = configuration.hasEffectTransition
			}
			updateDynamicDiagram(currentVariables)
		]
		if (configuration.hasEffectTransition && withEffectTransition) {
			Thread.sleep(configuration.effectTransitionDelay)
			RunInUI.runInUI [
				configuration.firstTimeRefreshView = false
				updateDynamicDiagram(currentVariables)
			]
		}
	}
		
	def static dispatch hadVariable(VariableModel variableModel) {
		variableModel.variable.value === null || oldVariableValues.get(variableModel.variable.toString) !== null
	}

	def static dispatch hadVariable(Shape shape) {
		false
	}
	
	override doGetActionRegistry(ActionRegistry actionRegistry) {
		// Contextual menu for objects
		actionRegistry.registerAction(new DeleteObjectAction(this, graphicalViewer, configuration))
	}
	
	override createEditPartFactory() {
		new DynamicDiagramEditPartFactory
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
