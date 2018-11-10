package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import java.util.List
import java.util.Map
import org.eclipse.core.resources.IProject
import org.eclipse.emf.common.util.URI
import org.eclipse.jface.dialogs.Dialog
import org.eclipse.jface.resource.JFaceResources
import org.eclipse.jface.resource.LocalResourceManager
import org.eclipse.jface.resource.ResourceManager
import org.eclipse.jface.viewers.DoubleClickEvent
import org.eclipse.jface.viewers.ITreeContentProvider
import org.eclipse.jface.viewers.ITreeSelection
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.swt.SWT
import org.eclipse.swt.events.KeyEvent
import org.eclipse.swt.events.KeyListener
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.layout.RowLayout
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.Event
import org.eclipse.swt.widgets.Shell
import org.eclipse.swt.widgets.Text
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.diagrams.Activator
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.allWollokFiles
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.convertToEclipseURI

class AddOutsiderClassView extends Dialog {

	Text searchText
	TreeViewer treeWollokElements
	Button addButton

	StaticDiagramConfiguration configuration
	IProject project

	new(StaticDiagramConfiguration configuration) {
		super(Display.getCurrent().activeShell)
		this.configuration = configuration
		this.project = configuration.resource.project
	}

	override configureShell(Shell shell) {
		super.configureShell(shell)
		shell.setText(Messages.StaticDiagram_AddOutsiderClass_WindowTitle)
	}

	override createContents(Composite parent) {
		val compositeLayout = new GridLayout(1, false) 
		val composite = new Composite(parent, SWT.NONE) => [
			layout = compositeLayout
		]
		val buttonGroup = new Composite(parent, SWT.NONE) => [
			layout = new RowLayout => [
				type = SWT.HORIZONTAL
				marginTop = 0
				marginBottom = 1
				marginWidth = 2	
				spacing = 2
				fill = true
			]
		]

		// Search text
		searchText = new Text(composite, SWT.SINGLE.bitwiseOr(SWT.BORDER)) => [
    		setLayoutData(new GridData(GridData.HORIZONTAL_ALIGN_FILL))
			addKeyListener(new KeyListener() {
				
				override keyPressed(KeyEvent arg0) {
				}
				
				override keyReleased(KeyEvent arg0) {
					treeWollokElements => [
						refresh(true)
						expandAll
					]
				}
			})	
		]

		// Tree viewer
		treeWollokElements = new TreeViewer(composite, SWT.V_SCROLL.bitwiseOr(SWT.BORDER).bitwiseOr(SWT.MULTI))
		
		// Buttons
		addButton = new Button(buttonGroup, SWT.PUSH) => [
			enabled = false
			text = Messages.StaticDiagram_AddOutsiderClass_AcceptButton
			addListener(SWT.Selection,
				[ Event event |
					val iterator = (treeWollokElements.selection as ITreeSelection).iterator
					while (iterator.hasNext) {
						val element = iterator.next as WMethodContainer
						configuration.addOutsiderElement(element)
					}
					this.close
				]
			)
		]
		new Button(buttonGroup, SWT.PUSH) => [
			text = Messages.StaticDiagram_AddOutsiderClass_CancelButton
			addListener(SWT.Selection, [ event |
				this.close
			])
		]
		treeWollokElements => [
			val mapMethodContainers = project.mapMethodContainers(configuration.platformFile)
			// Show wollok files
			// - that have any valid method container
			// - avoiding current resource of static diagram
			var List<URI> wollokFiles = newArrayList
			if (!configuration.platformFile) {
				wollokFiles = project.allWollokFiles.filter [
					!mapMethodContainers.get(it).isEmpty && it !== configuration.resource.convertToEclipseURI
				].toList
			}
			control.layoutData = new GridData(SWT.FILL, SWT.FILL, true, true, 1, 0) => [
				heightHint = 350
				widthHint = 250
			]
			addDoubleClickListener([ DoubleClickEvent event |
					val selection = event.selection as ITreeSelection
					if (selection.firstElement instanceof WMethodContainer) {
						configuration.addOutsiderElement(selection.firstElement as WMethodContainer)
						this.close
					}
				]
			)
			addSelectionChangedListener([ event |
				val selection = event.selection as ITreeSelection
				addButton.enabled = selection !== null && selection.firstElement instanceof WMethodContainer
			])
			contentProvider = new WollokMethodContainerContentProvider(mapMethodContainers, searchText)
			labelProvider = new WollokMethodContainerLabelProvider
			input = wollokFiles
			expandAll
		]
		composite
	}

}

class WollokMethodContainerContentProvider implements ITreeContentProvider {

	Map<URI, List<WMethodContainer>> methodContainers
	Text searchText

	new(Map<URI, List<WMethodContainer>> methodContainers, Text searchText) {
		this.methodContainers = methodContainers
		this.searchText = searchText
	}

	def dispatch getChildren(Object o) {
		#[]
	}

	def dispatch getChildren(URI uri) {
		val children = methodContainers.get(uri) ?: #[]
		children.filter[ !AbstractModel.allElements.map [ identifier ].contains(it.identifier) && (searchText.text === null || it.identifier.toUpperCase.contains(searchText.text.toUpperCase)) ].toList
	}

	def dispatch getElements(Object o) {
		#[]
	}

	def dispatch getElements(List<URI> inputElements) {
		inputElements
	}

	def dispatch getParent(WMethodContainer mc) { mc.file.URI }

	def dispatch getParent(Object o) { null }

	def dispatch hasChildren(URI uri) { !uri.getChildren.isEmpty }

	def dispatch hasChildren(Object element) { false }

	override dispose() {}

	override inputChanged(Viewer viewer, Object oldInput, Object newInput) {
	}

}

class WollokMethodContainerLabelProvider extends LabelProvider {

	private ResourceManager resourceManager = new LocalResourceManager(JFaceResources.getResources())

	def dispatch getImage(WClass element) { showImage("wollok-icon-class_16.png") }

	def dispatch getImage(WNamedObject element) { showImage("wollok-icon-object_16.png") }

	def dispatch getImage(WMixin element) { showImage("wollok-icon-mixin_16.png") }

	def dispatch getImage(URI uri) {
		val fileExtension = uri.fileExtension
		if (fileExtension.equals(WollokConstants.TEST_EXTENSION)) {
			return showImage("wollok-icon-test_16.png")
		}
		if (fileExtension.equals(WollokConstants.PROGRAM_EXTENSION)) {
			return showImage("wollok-icon-program_16.png")
		}
		return showImage("w.png")
	}

	def dispatch getImage(Object element) {
		showImage("w.png")
	}

	def showImage(String path) {
		val imageDescriptor = Activator.getDefault.getImageDescriptor("icons/" + path)
		resourceManager.createImage(imageDescriptor)
	}

	def dispatch getText(WMethodContainer mc) {
		return mc.name
	}

	def dispatch getText(URI uri) {
		uri.lastSegment
	}

	def dispatch getText(Object o) {
		o.toString
	}

	override def dispose() {
		super.dispose
		resourceManager.dispose
	}
}
