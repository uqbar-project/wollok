package org.uqbar.project.wollok.ui.editor.annotations

import com.google.inject.Inject
import java.util.ResourceBundle
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.jface.text.BadLocationException
import org.eclipse.jface.text.source.IAnnotationModelExtension2
import org.eclipse.ui.texteditor.ITextEditorActionConstants
import org.eclipse.ui.texteditor.IUpdate
import org.eclipse.ui.texteditor.ResourceAction
import org.eclipse.ui.texteditor.SelectMarkerRulerAction
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.XtextUIMessages
import org.eclipse.xtext.ui.editor.GlobalURIEditorOpener
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.XtextMarkerRulerAction
import org.eclipse.xtext.ui.editor.actions.IActionContributor
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Action performed when the user clicks on the arrow to navigate to the overridden method.
 * 
 * @author jfernandes
 */
class WOverrideRulerAction extends ResourceAction implements IActionContributor, IUpdate {
	static val RESOURCE_BUNDLE = ResourceBundle.getBundle(WollokActivator.BUNDLE_NAME)
	static val RESOURCE_KEY_PREFIX = "WOverrideRulerAction.OpenSuperMethod."
	XtextEditor editor
	SelectMarkerRulerAction selectMarkerRulerAction
	WOverrideAnnotation overrideIndicatorAnnotation
	@Inject
	GlobalURIEditorOpener uriEditorOpener
		
	new() {
		super(RESOURCE_BUNDLE, "WOverrideRulerAction")
		setId(WOverrideRulerAction.name)
		setActionDefinitionId(id)
	}
	
	override contributeActions(XtextEditor editor) {
		this.editor = editor;
		selectMarkerRulerAction = createMarkerRulerAction()
		editor.setAction(ITextEditorActionConstants.RULER_CLICK, this)
		enabled = true
	}
	
	def createMarkerRulerAction() {
		new XtextMarkerRulerAction(
			XtextUIMessages.getResourceBundle(),
			"XtextSelectAnnotationRulerAction.", 
			editor, 
			editor.verticalRuler)
	}
	
	override editorDisposed(XtextEditor editor) {
	}
	
	override update() {
		overrideIndicatorAnnotation = findOverrideIndicatorAnnotation
		selectMarkerRulerAction.update
		enabled = selectMarkerRulerAction.enabled || overrideIndicatorAnnotation !== null
	}
	
	def findOverrideIndicatorAnnotation() {
		val verticalRuler = editor.verticalRuler
		val lineOfLastMouseButtonActivity = verticalRuler.lineOfLastMouseButtonActivity
		val annotationModel = verticalRuler.model as IAnnotationModelExtension2
		if (annotationModel !== null) {
			try {
				val line = editor.document.getLineInformation(lineOfLastMouseButtonActivity)
				return annotationModel.getAnnotationIterator(line.offset, line.length + 1, true, true)
					.findFirst[it instanceof WOverrideAnnotation] as WOverrideAnnotation 
			} catch (BadLocationException e) {
			}
		}
		null
	}
	
	// run
	
	override run() {
		if (overrideIndicatorAnnotation !== null) {
			initialize(RESOURCE_BUNDLE, RESOURCE_KEY_PREFIX)
			runInternal
		} 
		else {
			initialize(XtextUIMessages.getResourceBundle(), "XtextSelectAnnotationRulerAction.")
			selectMarkerRulerAction.run
		}
	}

	def runInternal() {
		editor.document.readOnly[XtextResource resource |
			val method = resource.getEObject(overrideIndicatorAnnotation.methodURI) as WMethodDeclaration
			uriEditorOpener.open(EcoreUtil.getURI(method.overridenMethod), true)
		]
	}
	
}