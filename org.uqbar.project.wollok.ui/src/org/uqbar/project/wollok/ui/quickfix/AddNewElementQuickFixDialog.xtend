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
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.Font
import org.eclipse.swt.graphics.FontData
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.layout.RowLayout
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.Event
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Listener
import org.eclipse.swt.widgets.Shell
import org.eclipse.swt.widgets.Text
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.uqbar.project.wollok.ui.Messages
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.validation.ElementNameValidation
import org.uqbar.project.wollok.wollokDsl.Import
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static org.uqbar.project.wollok.WollokConstants.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.quickfix.QuickFixUtils.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * QuickFix Wizard Dialog that helps user to define a new element, like
 * 
 * - a wko or named object
 * - a class
 * 
 */
class AddNewElementQuickFixDialog extends Dialog {

	// SWT - UI References
	Button[] radioButtonsNewOrNot	
	Text inputNewFileName
	Label errorMessage
	TreeViewer treeWollokElements
	Button newFileRadio
	Button addButton

	// DSL - XText References
	IProject project
	IResource resource
	IModificationContext context
	EObject originalEObject
	
	// Element - Object or class to create
	String elementName
	String newFileName
	boolean generatesWKO
	List<URI> wollokFiles

	public static val MAX_WIDTH = 300
	public static val OK = "Ok"
	public static val COLOR_WHITE = new Color(Display.current, 234, 234, 234)
	public static val COLOR_BLACK = new Color(Display.current, 0, 0, 0)
	public static val COLOR_RED = new Color(Display.current, 240, 10, 0)
		
	new(String elementName, boolean generatesWKO, IResource resource, IModificationContext context, EObject originalEObject) {
		super(Display.getCurrent().activeShell)
		this.elementName = elementName
		this.computeFileName(elementName, true)
		this.generatesWKO = generatesWKO
		this.project = resource.project
		this.resource = resource
		this.context = context
		this.originalEObject = originalEObject
		this.open
	}

	override configureShell(Shell shell) {
		super.configureShell(shell)
		if (this.generatesWKO) 
			shell.setText(Messages.AddNewWKOQuickFix_Title)
		else 
			shell.setText(Messages.AddNewClassQuickFix_Title)
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

		val titleComposite = new Composite(composite, SWT.BORDER) => [
			layout = new GridLayout => [ numColumns = 2 ]
 			layoutData = new GridData => [
				grabExcessHorizontalSpace = false
			]
		]
		
		val icon = showImage(windowIcon)
		new Label(titleComposite, SWT.NONE.bitwiseOr(SWT.RIGHT)) => [
 			layoutData = new GridData => [
				grabExcessHorizontalSpace = false
			]
			image = icon 
		]
 
 		val labelTitle = new Label(titleComposite, SWT.LEFT) => [
 			layoutData = new GridData => [
				grabExcessHorizontalSpace = false
				widthHint = MAX_WIDTH + 100
				heightHint = 25
			]
			text = elementName
 		]
 		
 		val fontData = labelTitle.font.fontData.get(0)
		val newFont = new Font(Display.current, new FontData(fontData.name, 14, fontData.style))
		labelTitle.font = newFont

		newFileRadio = new Button(composite, SWT.RADIO) => [
			text = Messages.AddNewElementQuickFix_NewFile_Title
			selection = true
			addListener(SWT.Selection, fileSelectionListener)
		]

		val fileNameComposite = new Composite(composite, SWT.NONE) => [
			layout = new GridLayout => [ numColumns = 2 ]
		]		
		inputNewFileName = new Text(fileNameComposite, SWT.SINGLE.bitwiseOr(SWT.BORDER)) => [
			text = this.newFileName
			layoutData = new GridData => [
				horizontalAlignment = SWT.FILL
				grabExcessHorizontalSpace = false
				widthHint = MAX_WIDTH
			]
			addKeyListener(new KeyListener() {
				
				override keyPressed(KeyEvent event) {
					val char DOT = '.'
					event.doit = !(ElementNameValidation.INVALID_RESOURCE_CHARACTERS.contains(event.character) || event.character == DOT)
				}
				
				override keyReleased(KeyEvent arg0) {
					AddNewElementQuickFixDialog.this.computeFileName(inputNewFileName.text)
				}
			})	
		]

		new Label(fileNameComposite, SWT.LEFT) => [
			text = "." + WOLLOK_DEFINITION_EXTENSION
		]

		errorMessage = new Label(composite,SWT.CENTER.bitwiseOr(SWT.BORDER)) => [
			layoutData = new GridData => [
				grabExcessHorizontalSpace = false
				widthHint = MAX_WIDTH + 100
				heightHint = 25
			]
			background = COLOR_WHITE
			text = ""
		]
		
		new Label(composite, SWT.SEPARATOR.bitwiseOr(SWT.HORIZONTAL)) => [
			layoutData = new GridData => [
				widthHint = MAX_WIDTH + 100
			]
		]
		
		val existingFileRadio = new Button(composite, SWT.RADIO) => [
			text = Messages.AddNewElementQuickFix_ExistingFile_Title
			addListener(SWT.Selection, fileSelectionListener)
		]
		
		radioButtonsNewOrNot = #[newFileRadio, existingFileRadio]

		// Tree viewer
		treeWollokElements = new TreeViewer(composite, SWT.V_SCROLL.bitwiseOr(SWT.BORDER).bitwiseOr(SWT.MULTI))
		
		// Buttons
		addButton = new Button(buttonGroup, SWT.PUSH) => [
			enabled = false
			text = Messages.AddNewElementQuickFix_Accept
			addListener(SWT.Selection,
				[ Event event |
					AddNewElementQuickFixDialog.this.outputCodeIntoFile
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
			wollokFiles = project.allWollokFiles.filter [ fileExtension.equals(WOLLOK_DEFINITION_EXTENSION) ].toList
			control.layoutData = new GridData(SWT.FILL, SWT.FILL, true, true, 1, 0) => [
				heightHint = 220
				widthHint = 250
			]
			addDoubleClickListener([ DoubleClickEvent event | 
				AddNewElementQuickFixDialog.this.outputCodeIntoFile
				AddNewElementQuickFixDialog.this.close
			])
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
	
	def getWindowIcon() {
		if (this.generatesWKO) "wollok-icon-object_16.png" else "wollok-icon-class_16.png"
	}

	def void computeFileName(String elementName) {
		this.computeFileName(elementName, false)	
	}
	
	def void computeFileName(String elementName, boolean initialState) {
		this.newFileName = elementName.toLowerCase
		if (!initialState) setButtonOkAvailability
	}
	
	def void setButtonOkAvailability() {
		val selection = treeWollokElements.selection as ITreeSelection
		addButton.enabled = (selection !== null && selection.firstElement instanceof URI) || (newFileRadio.selection && newFileName.isValid)
		val message = this.inputFileNameValidationMessage
		errorMessage.text = message
		errorMessage.foreground = if (message.equals(OK)) COLOR_BLACK else COLOR_RED 
	}
	
	def setReadOnlyControls() {
		inputNewFileName.enabled = newFileRadio.selection
		treeWollokElements.control.enabled = !newFileRadio.selection
		if (!treeWollokElements.control.getEnabled) {
			treeWollokElements.selection = null
		}
	}
	
	def isValid(String newFileName) {
		newFileName.notBlank && !newFileName.substring(0, 1).isNumeric && !fullNewFileName.alreadyExists	
	}
	
	def getFullNewFileName() {
		newFileName + "." + WOLLOK_DEFINITION_EXTENSION 
	}
	
	def getInputFileNameValidationMessage() {
		if (!newFileName.notBlank) {
			return Messages.AddNewElementQuickFix_NewFileCannotBeBlank_ErrorMessage
		}
		if (newFileName.substring(0, 1).isNumeric) {
			return Messages.AddNewElementQuickFix_NewFileCannotStartWithNumber_ErrorMessage
		}
		if (fullNewFileName.alreadyExists) {
			return Messages.AddNewElementQuickFix_NewFileAlreadyExists_ErrorMessage
		}
		OK
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

	def void outputCodeIntoFile() {
		if (newFileRadio.selection) {
			// Adding element definition
			val rawFolder = resource.parent.locationURI.rawPath
			val newFile = rawFolder + File.separator + fullNewFileName
			newFile.outputCodeIntoFile(code)
			// Adding import to generated element
			resource.refreshProject
			context.addImportCode(newFileName, resource)
		} else {
			// Adding element definition
			val uri = (treeWollokElements.selection as ITreeSelection).firstElement as URI
			uri.devicePath.outputCodeIntoFile(code)
			
			// Adding import if it does not exists
			val imports = originalEObject.allImports.map [ importedNamespace ]
			val newElement = context.getXtextDocument(uri).readOnly(objectOrClass).findFirst [ it.fqn.contains(elementName) ]
			val elementPackage = newElement.implicitPackage
			originalEObject.refreshProject
			if (!imports.exists [ it.contains(elementPackage) ]) {
				context.addImportCode(elementPackage, resource)
			}
		}
	}
	
	def void addImportCode(IModificationContext context, String importedPackage, IResource resource) {
		var importCode = IMPORT + " " + importedPackage + ".*" + System.lineSeparator
		if (context.xtextDocument.readOnly [ getAllOfType(Import)].isEmpty) {
			importCode += System.lineSeparator
		}
		context.xtextDocument.replace(0, 0, importCode)
		resource.refreshProject
	}
	
	
	def outputCodeIntoFile(String uri, String code) {
		new BufferedWriter(new FileWriter(uri, true)) => [
			append(System.lineSeparator + code)
			close
		]
	}

	def (XtextResource) => Iterable<? extends WMethodContainer> getObjectOrClass() {
		if (this.generatesWKO)
			[ it.getAllOfType(WNamedObject) ]
		else 
			[ it.getAllOfType(WClass) ]
	}
	
	def getCode() {
		if (generatesWKO) elementName.generateNewWKOCode else elementName.generateNewClassCode	
	}

	def showImage(String path) {
		val imageDescriptor = WollokActivator.instance.getImageDescriptor("icons/" + path)
		new LocalResourceManager(JFaceResources.getResources()).createImage(imageDescriptor)
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

	ResourceManager resourceManager = new LocalResourceManager(JFaceResources.getResources())

	def dispatch getImage(WClass element) { showImage("wollok-icon-class_16.png") }

	def dispatch getImage(WNamedObject element) { showImage("wollok-icon-object_16.png") }

	def dispatch getImage(WMixin element) { showImage("wollok-icon-mixin_16.png") }

	def dispatch getImage(URI uri) {
		val fileExtension = uri.fileExtension
		if (fileExtension.equals(TEST_EXTENSION)) {
			return showImage("wollok-icon-test_16.png")
		}
		if (fileExtension.equals(PROGRAM_EXTENSION)) {
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

	override dispose() {
		super.dispose
		resourceManager.dispose
	}
	
}
