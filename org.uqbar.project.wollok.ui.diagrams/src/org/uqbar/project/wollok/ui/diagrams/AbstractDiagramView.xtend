package org.uqbar.project.wollok.ui.diagrams

import java.util.List
import org.eclipse.core.runtime.Platform
import org.eclipse.draw2d.ColorConstants
import org.eclipse.gef.ContextMenuProvider
import org.eclipse.gef.DefaultEditDomain
import org.eclipse.gef.EditPartFactory
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.commands.CommandStack
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart
import org.eclipse.gef.editparts.ZoomManager
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.gef.ui.actions.ZoomInAction
import org.eclipse.gef.ui.actions.ZoomOutAction
import org.eclipse.gef.ui.palette.FlyoutPaletteComposite
import org.eclipse.gef.ui.palette.PaletteViewerProvider
import org.eclipse.gef.ui.parts.GraphicalViewerKeyHandler
import org.eclipse.gef.ui.parts.ScrollingGraphicalViewer
import org.eclipse.gef.ui.parts.SelectionSynchronizer
import org.eclipse.jface.action.IAction
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
import org.eclipse.ui.handlers.IHandlerService
import org.eclipse.ui.part.ViewPart
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.editor.ISourceViewerAware
import org.uqbar.project.wollok.ui.diagrams.classes.model.StaticDiagram
import org.uqbar.project.wollok.ui.diagrams.classes.palette.CustomPalettePage
import org.uqbar.project.wollok.ui.diagrams.dynamic.WollokFlyoutPreferences

abstract class AbstractDiagramView extends ViewPart implements ISelectionListener, ISourceViewerAware, IPartListener, ISelectionProvider, ISelectionChangedListener {

	@Accessors DefaultEditDomain editDomain
	@Accessors(PUBLIC_GETTER) GraphicalViewer graphicalViewer
	@Accessors(PUBLIC_GETTER) SelectionSynchronizer synchronizer
	@Accessors(PUBLIC_GETTER) ActionRegistry actionRegistry

	@Accessors StaticDiagram diagram
	@Accessors(PUBLIC_GETTER) IViewSite site

	@Accessors(PUBLIC_GETTER) IAction zoomIn
	@Accessors(PUBLIC_GETTER) IAction zoomOut

	// splitter and palette
	@Accessors(PUBLIC_GETTER) FlyoutPaletteComposite splitter
	@Accessors CustomPalettePage page
	@Accessors PaletteViewerProvider provider

	// selection provider
	val List<ISelectionChangedListener> listeners = newArrayList
	var ISelection selection = null

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

	abstract def void configureToolbar()

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
		graphicalViewer => [
			control.background = ColorConstants.listBackground
			editPartFactory = createEditPartFactory
			rootEditPart = new ScalableFreeformRootEditPart
			keyHandler = new GraphicalViewerKeyHandler(it)

			val cmProvider = getContextMenuProvider(it, getActionRegistry)
			contextMenu = cmProvider
			if (shouldRegisterContextMenu) {
				site.registerContextMenu(cmProvider, it)
			}
		]
	}

	def getSelectionSynchronizer() {
		if (synchronizer === null)
			synchronizer = new SelectionSynchronizer
		synchronizer
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

	def EditPartFactory createEditPartFactory()

	abstract def void layout()

	def getActionRegistry() {
		if (actionRegistry === null) {
			actionRegistry = new ActionRegistry => [
				doGetActionRegistry
				
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
		}
		actionRegistry
	}

	abstract def void doGetActionRegistry(ActionRegistry actionRegistry)

	abstract def ContextMenuProvider getContextMenuProvider(GraphicalViewer graphicalViewer,
		ActionRegistry actionRegistry)

	def shouldRegisterContextMenu() { false }

	override setFocus() {
		graphicalViewer.control.setFocus
	}

	def setGraphicalViewer(GraphicalViewer viewer) {
		editDomain.addViewer(viewer)
		graphicalViewer = viewer
		graphicalViewer => [
			addSelectionChangedListener(this)
		]
	}

	def getModel() {
		diagram
	}

	def CommandStack getCommandStack() {
		editDomain.commandStack
	}

	// ****************************	
	// ** Palette
	// ****************************
	def getPalettePreferences() {
		val preferencesService = Platform.getPreferencesService() // as PreferenceServices 
		new WollokFlyoutPreferences(preferencesService.rootNode)
	}

	def getPaletteViewerProvider() {
		if (provider === null) {
			provider = createPaletteViewerProvider
		}
		provider
	}

	def createPaletteViewerProvider() { new PaletteViewerProvider(editDomain) }

	// ****************************	
	// ** Part listener (listen for open editor)
	// ****************************
	override partActivated(IWorkbenchPart part) {}

	override partBroughtToTop(IWorkbenchPart part) {}

	override partClosed(IWorkbenchPart part) {}

	override partDeactivated(IWorkbenchPart part) {}

	override partOpened(IWorkbenchPart part) {}

	override selectionChanged(IWorkbenchPart part, ISelection selection) {}

	override setSourceViewer(ISourceViewer sourceViewer) {}

	override addSelectionChangedListener(ISelectionChangedListener listener) { listeners += listener }

	override getSelection() { selection }

	override setSelection(ISelection selection) {}

	override removeSelectionChangedListener(ISelectionChangedListener listener) { listeners -= listener }

	override selectionChanged(SelectionChangedEvent event) {}

	def List<ISelectionChangedListener> getCurrentListeners() { listeners }

	override dispose() {
		site.workbenchWindow.selectionService.removeSelectionListener(this)
		editDomain.activeTool = null
		if(actionRegistry !== null) actionRegistry.dispose

		if (Display.current !== null) super.dispose
	}

}
