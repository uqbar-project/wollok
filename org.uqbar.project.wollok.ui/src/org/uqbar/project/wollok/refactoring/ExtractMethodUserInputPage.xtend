package org.uqbar.project.wollok.refactoring

import com.google.inject.Inject
import org.eclipse.jdt.internal.corext.refactoring.ParameterInfo
import org.eclipse.jdt.internal.ui.refactoring.ChangeParametersControl
import org.eclipse.jdt.internal.ui.refactoring.IParameterListChangeListener
import org.eclipse.jface.dialogs.Dialog
import org.eclipse.ltk.core.refactoring.RefactoringStatus
import org.eclipse.ltk.ui.refactoring.UserInputWizardPage
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.embedded.EmbeddedEditor
import org.eclipse.xtext.ui.editor.embedded.EmbeddedEditorFactory
import org.eclipse.xtext.ui.editor.embedded.EmbeddedEditorModelAccess
import org.eclipse.xtext.ui.refactoring.impl.ProjectUtil
import org.eclipse.xtext.ui.resource.IResourceSetProvider
import org.uqbar.project.wollok.wollokDsl.WNamed

import static org.eclipse.xtext.util.Strings.*
import org.uqbar.project.wollok.ui.Messages

/**
 * 
 * @author jfernandes
 */
class ExtractMethodUserInputPage extends UserInputWizardPage {
	@Inject
	private EmbeddedEditorFactory editorFactory
	@Inject
	private IResourceSetProvider resourceSetProvider
	@Inject
	private ProjectUtil projectUtil
	@Accessors ExtractMethodRefactoring refactoring
	private Text textField
	private EmbeddedEditor signaturePreview
	private EmbeddedEditorModelAccess partialEditor
	private boolean isInitialName = true
	
	new() {
		super("ExtractMethodInputPage")
	}
	
	override createControl(Composite parent) {
		control = new Composite(parent, SWT.NONE) => [
			layout = new GridLayout(2, false)
			
			initializeDialogUnits
			createNameField
	
			createParameterControl
			createSeparator
			createSignaturePreview
			
			Dialog.applyDialogFont(it)
		]
	}
	
	def createNameField(Composite result) {
		new Label(result, SWT.NONE) => [ text = Messages.ExtractMethodUserInputPage_methodName ]
		
		textField = new Text(result, SWT.BORDER) => [
			text = refactoring.methodName
			addModifyListener [e | textModified(text) ]
			layoutData = new GridData(GridData.FILL_HORIZONTAL)			
		]
	}
	
	def createParameterControl(Composite result) {
		if (!refactoring.parameterInfos.empty) {
			val cp = new ChangeParametersControl(result, SWT.NONE,
					"Parameters", new IParameterListChangeListener() {
						override def parameterChanged(ParameterInfo parameter) { parameterModified }
						override def parameterListChanged() { parameterModified }
						override def parameterAdded(ParameterInfo parameter) { updatePreview }
					}, ChangeParametersControl.Mode.EXTRACT_METHOD)
			cp.layoutData = new GridData(GridData.FILL_BOTH) => [ horizontalSpan = 2 ]
			cp.input = refactoring.parameterInfos
		}
	}
	
	def String getText() { textField?.text }

	def textModified(String text) {
		isInitialName = false
		refactoring.methodName = text
		val status = validatePage(true)
		if (!status.hasFatalError)
			updatePreview
		pageComplete = status
	}

	def parameterModified() {
		updatePreview
		pageComplete = validatePage(false)
	}

	def updatePreview() {
		if (signaturePreview != null)
			partialEditor.updateModel(partialEditorModelPrefix, refactoring.methodSignature, partialEditorModelSuffix)
	}
	
	def String getPartialEditorModelPrefix() {
		"class " + (refactoring.getXtendClass as WNamed).name + " {"
	}
	
	def String getPartialEditorModelSuffix() { "() {} }" }
	
	def validatePage(boolean text) {
		val result = new RefactoringStatus
		if (text) {
			result.merge(validateMethodName)
			result.merge(validateParameters)
		} 
		else {
			result.merge(validateParameters)
			result.merge(validateMethodName)
		}
		result
	}
	
	def RefactoringStatus validateMethodName() {
		val result = new RefactoringStatus
		val text = getText()
		if (isEmpty(text)) {
			if (!isInitialName)
				result.addFatalError(Messages.ExtractMethodUserInputPage_provideMethodName)
			return result
		}
		result.merge(refactoring.validateMethodName(text))
		result
	}
	
	def RefactoringStatus validateParameters() {
		new RefactoringStatus => [
			merge(refactoring.validateParameters)			
		]
	}
	
	def createSeparator(Composite result) {
		new Label(result, SWT.SEPARATOR.bitwiseOr(SWT.HORIZONTAL)) => [
			layoutData = new GridData(GridData.FILL_HORIZONTAL) => [
				horizontalSpan = 2
			]
		]
	}
	
	def createSignaturePreview(Composite composite) {
		new Label(composite, SWT.NONE) => [
			text = Messages.ExtractMethodUserInputPage_methodSignaturePreview
			layoutData = new GridData(SWT.FILL) => [ horizontalSpan = 2 ]
		]
		
		signaturePreview = editorFactory.newEditor[|
				val resourceURI = EcoreUtil2.getPlatformResourceOrNormalizedURI(refactoring.xtendClass).trimFragment
				val project = projectUtil.getProject(resourceURI)
				val resourceSet = resourceSetProvider.get(project)
				resourceSet.getResource(resourceURI, true) as XtextResource
			].readOnly.withParent(composite)
			
		signaturePreview.viewer.control.layoutData = new GridData(GridData.FILL_HORIZONTAL) => [ horizontalSpan = 2 ] 
		partialEditor = signaturePreview.createPartialEditor(partialEditorModelPrefix, refactoring.methodSignature, partialEditorModelSuffix, true)
	}
	
}