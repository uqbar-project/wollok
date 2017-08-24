package org.uqbar.project.wollok.ui.quickfix

import java.io.BufferedWriter
import java.io.File
import java.io.FileWriter
import java.util.List
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
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
import org.eclipse.swt.widgets.Listener
import org.eclipse.swt.widgets.Shell
import org.eclipse.swt.widgets.Text
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.validation.ElementNameValidation
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static org.uqbar.project.wollok.WollokConstants.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * QuickFix Wizard Dialog that helps user to define a new element, like
 * 
 * - a wko or named object
 * - a class
 * 
 */
class AddNewElementQuickFixDialog extends Dialog {

	Button[] radioButtonsNewOrNot	
	Text inputNewFileName
	TreeViewer treeWollokElements
	Button newFileRadio
	Button addButton

	IProject project
	IResource resource
	IModificationContext context
	EObject originalEObject
	
	// Element - Object or class to create
	String elementName
	String newFileName
	String code
	
	List<URI> wollokFiles
	
	Composite treeComposite
	
	new(String elementName, String code, IResource resource, IModificationContext context, EObject originalEObject) {
		super(Display.getCurrent().activeShell)
		this.computeFileName(elementName, true)
		this.code = code
		this.project = resource.project
		this.resource = resource
		this.context = context
		this.originalEObject = originalEObject
		this.open
	}

	override configureShell(Shell shell) {
		super.configureShell(shell)
		shell.setText(Messages.AddNewElementQuickFix_Title)
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
		
		val fileSelectionListener = new Listener() {
			override handleEvent(Event event) {
				AddNewElementQuickFixDialog.this.setButtonOkAvailability
				AddNewElementQuickFixDialog.this.setReadOnlyControls
			}
		}

		newFileRadio = new Button(composite, SWT.RADIO) => [
			text = Messages.AddNewElementQuickFix_NewFile_Title
			selection = true
			addListener(SWT.Selection, fileSelectionListener)
		]
		
		inputNewFileName = new Text(composite, SWT.SINGLE.bitwiseOr(SWT.BORDER)) => [
			text = this.elementName
    		setLayoutData(new GridData(GridData.HORIZONTAL_ALIGN_FILL))
			addKeyListener(new KeyListener() {
				
				override keyPressed(KeyEvent event) {
					if (ElementNameValidation.INVALID_RESOURCE_CHARACTERS.contains(event.character)) {
						event.doit = false
					}
				}
				
				override keyReleased(KeyEvent arg0) {
					AddNewElementQuickFixDialog.this.computeFileName(inputNewFileName.text)
//					if (AddNewElementQuickFixDialog.this.newFileName.alreadyExists) {
//						new MessageBox(composite.shell, SWT.ICON_ERROR) => [
//							message = Messages.AddNewElementQuickFix_NewFileAlreadyExists_ErrorMessage 
//						]
//					} 
				}
			})	
		]

		val existingFileRadio = new Button(composite, SWT.RADIO) => [
			text = Messages.AddNewElementQuickFix_ExistingFile_Title
			addListener(SWT.Selection, fileSelectionListener)
		]
		
		radioButtonsNewOrNot = #[newFileRadio, existingFileRadio]

		// Tree viewer
		treeComposite = new Composite(composite, SWT.NONE) => [
			layout = new GridLayout => [ numColumns = 1 ]
		]
		treeWollokElements = new TreeViewer(treeComposite, SWT.V_SCROLL.bitwiseOr(SWT.BORDER).bitwiseOr(SWT.MULTI))
		
		// Buttons
		addButton = new Button(buttonGroup, SWT.PUSH) => [
			enabled = false
			text = Messages.AddNewElementQuickFix_Accept
			addListener(SWT.Selection,
				[ Event event |
					AddNewElementQuickFixDialog.this.generateCode
					this.close
				]
			)
		]
		new Button(buttonGroup, SWT.PUSH) => [
			text = Messages.AddNewElementQuickFix_Cancel
			addListener(SWT.Selection, [ event |
				this.close
			])
		]
		treeWollokElements => [
			// Show wollok files that have any valid method container
			wollokFiles = project.allWollokFiles
			control.layoutData = new GridData(SWT.FILL, SWT.FILL, true, true, 1, 0) => [
				heightHint = 220
				widthHint = 250
			]
			addDoubleClickListener([ DoubleClickEvent event | AddNewElementQuickFixDialog.this.generateCode	])
			addSelectionChangedListener([ event |
				setButtonOkAvailability
			])
			contentProvider = new WollokFileContentProvider
			labelProvider = new WollokMethodContainerLabelProvider
			input = wollokFiles
			expandAll
		]
		
		setButtonOkAvailability
		setReadOnlyControls
		
		composite
	}

	def void computeFileName(String elementName) {
		this.computeFileName(elementName, false)	
	}
	
	def void computeFileName(String elementName, boolean initialState) {
		this.elementName = elementName
		this.newFileName = elementName.toLowerCase + "." + CLASS_OBJECTS_EXTENSION
		if (!initialState) setButtonOkAvailability
	}
	
	def void setButtonOkAvailability() {
		val selection = treeWollokElements.selection as ITreeSelection
		addButton.enabled = (selection !== null && selection.firstElement instanceof URI) || (newFileRadio.selection && newFileName.isValid)
	}
	
	def setReadOnlyControls() {
		inputNewFileName.enabled = newFileRadio.selection
		treeComposite.enabled = !newFileRadio.selection
		if (!treeComposite.getEnabled) {
			treeWollokElements.selection = null
		}
	}
	
	def isValid(String newFileName) {
		elementName.notBlank && !elementName.substring(0).isNumeric && !newFileName.alreadyExists	
	}
	
	def isNumeric(String character) {
		try {
			new Integer(character)
			return true
		} catch (NumberFormatException e) { 
			return false
		}
	}
	
	def notBlank(String newFileName) {
		newFileName !== null && !newFileName.trim.equals("")	
	}
	
	def alreadyExists(String newFileName) {
		wollokFiles.exists [ it.lastSegment.equalsIgnoreCase(newFileName) ]		
	}

	def void generateCode() {
		// Adding element definition
		var BufferedWriter file
		if (newFileRadio.selection) {
			val rawFolder = resource.parent.locationURI.rawPath
			file = new BufferedWriter(new FileWriter(rawFolder + File.separator + newFileName))

			// Adding import to generated element
			val importCode = IMPORT + " " + elementName + ".*" + System.lineSeparator + System.lineSeparator
			context.xtextDocument.replace(0, 0, importCode)

			resource.refreshProject
		} else {
			val uri = (treeWollokElements.selection as ITreeSelection).firstElement as URI
			file = new BufferedWriter(new FileWriter(uri.devicePath, true))
			//context.xtextDocument.replace
			
			//val folder = resource.implicitPackage
			val imports = originalEObject.allImports
			//println("Folder " + folder)
			println("Imports " + imports.map [ importedNamespace ])
			// TODO: 1) a partir del file, tomar el Resource (por ahi cambiar el URI por un resource)
			// TODO: 2) OBTENER EL IMPLICIT PACKAGE DEL EOBJECT donde se generó el código (wollokModelExtensions)
			// TODO: 3) Revisar de cada import si alguno matchea el implicit package del eobject 
			// Imports [example.*, objects.abc]
			
		}
		file.append(System.lineSeparator + code)
		file.close
	}
	
}

class WollokFileContentProvider implements ITreeContentProvider {

	def dispatch getChildren(Object o) {
		#[]
	}

	def dispatch getChildren(URI uri) {
		#[]
	}

	def dispatch getElements(Object o) {
		#[]
	}

	def dispatch getElements(List<URI> inputElements) {
		inputElements
	}

	def dispatch getParent(URI uri) { uri.trimSegments(uri.segmentCount) }

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
		val imageDescriptor = WollokActivator.instance.getImageDescriptor("icons/" + path)
		resourceManager.createImage(imageDescriptor)
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
