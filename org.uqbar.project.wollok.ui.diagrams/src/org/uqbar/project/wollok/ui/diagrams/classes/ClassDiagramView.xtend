package org.uqbar.project.wollok.ui.diagrams.classes

import com.google.inject.Inject
import java.util.ArrayList
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.draw2d.ColorConstants
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.PositionConstants
import org.eclipse.draw2d.geometry.Point
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
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.ui.editor.ISourceViewerAware
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.XtextDocumentUtil
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassDiagram
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.MixinModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.NamedObjectModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.palette.ClassDiagramPaletterFactory
import org.uqbar.project.wollok.ui.diagrams.classes.parts.ClassDiagramEditPartFactory
import org.uqbar.project.wollok.ui.diagrams.classes.parts.ClassEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.InheritanceConnectionEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.MixinEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.NamedObjectEditPart
import org.uqbar.project.wollok.ui.internal.WollokDslActivator
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import java.util.Comparator

/**
 * 
 * @author jfernandes
 */
class ClassDiagramView extends ViewPart implements ISelectionListener, ISourceViewerAware, IPartListener, ISelectionProvider, ISelectionChangedListener, IDocumentListener {
	DefaultEditDomain editDomain
	GraphicalViewer graphicalViewer
	SelectionSynchronizer synchronizer
	ActionRegistry actionRegistry
	
	IXtextDocument xtextDocument
	
	@Inject
	XtextResourceSet resourceSet
	
	ClassDiagram diagram
	
	// splitter and palette
	FlyoutPaletteComposite splitter
	CustomPalettePage page
	PaletteViewerProvider provider
	
	new() {
		editDomain = new DefaultEditDomain(null)
		editDomain.paletteRoot = ClassDiagramPaletterFactory.create
	}
	
	override init(IViewSite site) throws PartInitException {
		super.init(site)
		// listen for selection
		site.workbenchWindow.selectionService.addSelectionListener(this)
		site.workbenchWindow.activePage.addPartListener(this)
	}
	
	def createDiagramModel() {
		NamedObjectModel.init()
		MixinModel.init()
		new ClassDiagram => [
			// classes
			val classes = xtextDocument.readOnly[ classes ].toSet
			ClassModel.init(classes.clone)
			classes.addAll(classes.clone.map[c| c.superClassesIncludingYourself].flatten)

			// objects (first so that we collect parents in the "classes" set
			val objects = xtextDocument.readOnly[ namedObjects ]
			
			objects.forEach[ o | 
				addNamedObject(new NamedObjectModel(o) => [ 
					locate
				])
				
				// Why should we add Object as a parent?
				//if (o.parent != null)
				//	classes.add(o.parent)
				//
				
				o.mixins.forEach[m | addMixin(m) ]
			]

			// classes
			// first, superclasses
			var classesCopy = classes.clone.filter [ it.parent == null ].toList
			var int level = 0
			while (!classesCopy.isEmpty) {
				level++
				val levelCopy = level
				classesCopy.forEach [ c | addClass(c, levelCopy) ]
				val parentClasses = classesCopy
				// then subclasses of parent classes and recursively...
				classesCopy = classes
					.clone
					.filter [ parentClasses.contains(it.parent) ]
					.sortWith([ WClass a, WClass b | 
						val parentA = a.parent?.name ?: ""
						val parentB = b.parent?.name ?: ""
						parentA.compareTo(parentB)
					] as Comparator<WClass>)
					.toList
					
			}

			// mixins
			classes.forEach[c, i| 
				c.mixins.forEach[m | addMixin(m) ]
			]
			//TODO: add mixins from document

			// relations
			connectRelations
		]
	}
	
	def getParentClass(WClass wclass) {
		if (wclass.parent == null) {
			return ""
		}
		wclass.parent.name
	}
	
	def getClasses(XtextResource it) { getAllOfType(WClass) }
	def getNamedObjects(XtextResource it) { getAllOfType(WNamedObject) }
	
	def <T extends EObject> Iterable<T> getAllOfType(XtextResource it, Class<T> type) {
		if (contents.empty) #[]
		else  (contents.get(0) as WFile).eAllContents.filter(type).toList
	}
	
	
	@Inject WollokClassFinder finder
	
	def getImportedClasses(XtextResource it) {
		val imports = getAllOfType(Import)
		imports.fold(newArrayList)[l, i |
			try {
				l.add(finder.getCachedClass(i, i.importedNamespace))
			}
			catch(WollokRuntimeException e) { }
			l
		]
	}
	
	override createPartControl(Composite parent) {
		splitter = new FlyoutPaletteComposite(parent, SWT.NONE, site.page, paletteViewerProvider, palettePreferences);
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
	}
	
	def configureGraphicalViewer() {
		graphicalViewer.control.background = ColorConstants.listBackground

		graphicalViewer.editPartFactory = new ClassDiagramEditPartFactory
		graphicalViewer.rootEditPart = new ScalableFreeformRootEditPart
		graphicalViewer.keyHandler = new GraphicalViewerKeyHandler(graphicalViewer)

		// configure the context menu provider
		val cmProvider = new ClassDiagramEditorContextMenuProvider(graphicalViewer, getActionRegistry)
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
		
		graph.edges.addAll(connectionsEditParts.map[c| 
			new Edge(nodes.findFirst[n| n.data == c.source.model], nodes.findFirst[n| n.data == c.target.model])
		])
		
		// layout
		val directedGraphLayout = new DirectedGraphLayout
		directedGraphLayout.visit(graph)
		
		
		// map back positions to model inverting the Y coordinates
		// because the directed graph only supports layout directo to SOUTH, meaning
		// super classes will be at the bottom. So we invert them
		val bottomNode = if (graph.nodes.empty) null else graph.nodes.maxBy[ (it as Node).y ] as Node

		graph.nodes.forEach[ val n = it as Node
			var deltaY = 10
			if (n != bottomNode) deltaY += bottomNode.height;
			(n.data as Shape).location = new Point(n.x, bottomNode.y - n.y + deltaY)
		]
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
	def getConnectionsEditParts() { getEditPartsOfType(InheritanceConnectionEditPart) }
	
	def <T> Iterable<T> getEditPartsOfType(Class<T> t) {
		(graphicalViewer.rootEditPart.children.get(0) as EditPart).children.filter(t)
	}
	
	def setGraphicalViewer(GraphicalViewer viewer) {
		editDomain.addViewer(viewer)
		graphicalViewer = viewer
		graphicalViewer.addSelectionChangedListener(this)
	}
	
	override setFocus() {
		graphicalViewer.control.setFocus
	}
	
	def getActionRegistry() {
		if (actionRegistry == null) actionRegistry = new ActionRegistry
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
			if (part.languageName == WollokDslActivator.ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL)
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
					ep.castedModel.clazz.name == c.text.toString 
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
					val wclazz = model.clazz
					this.selection = new StructuredSelection(wclazz)
					val e = new SelectionChangedEvent(this, this.selection)
					listeners.forEach[l| 
						l.selectionChanged(e)
					]
				}
			}
		}
	}
	
	
	
}