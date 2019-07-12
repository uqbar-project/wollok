package org.uqbar.project.wollok.refactoring

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.jface.text.ITextSelection
import org.eclipse.swt.widgets.Display
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.utils.EditorUtils
import org.eclipse.xtext.ui.refactoring.ui.RefactoringWizardOpenOperation_NonForking
import org.eclipse.xtext.ui.refactoring.ui.SyncUtil
import org.eclipse.xtext.xbase.ui.refactoring.RefactoredResourceCopier
import org.uqbar.project.wollok.wollokDsl.WExpression

/**
 * 
 * @author jfernandes
 */
class ExtractMethodHandler extends AbstractHandler {
	static val Logger LOG = Logger.getLogger(ExtractMethodHandler)
	@Inject	SyncUtil syncUtil
	@Inject	ExpressionUtil expressionUtil
	@Inject Provider<ExtractMethodRefactoring> refactoringProvider
	@Inject ExtractMethodWizard.Factory wizardFactory
	@Inject RefactoredResourceCopier resourceCopier
	
	
	override execute(ExecutionEvent event) throws ExecutionException {
		try {
			syncUtil.totalSync(false)
			val editor = EditorUtils.getActiveXtextEditor(event)
			if (editor !== null) {
				val selection = editor.selectionProvider.selection as ITextSelection
				val document = editor.document
				document.priorityReadOnly[ resource |
						val copiedResource = resourceCopier.loadIntoNewResourceSet(resource);
						val expressions = expressionUtil.findSelectedSiblingExpressions(copiedResource, selection)
						if (expressions.empty) return null						
						val extractMethodRefactoring = refactoringProvider.get
						if (extractMethodRefactoring.initialize(editor, expressions, true)) {
							updateSelection(editor, expressions)
							val wizard = wizardFactory.create(extractMethodRefactoring)
							val openOperation = new RefactoringWizardOpenOperation_NonForking(wizard)
							openOperation.run(editor.site.shell, "Extract Method")
						} else {
							return null
						}
				]
			}
		} 
		catch (InterruptedException e) {
			LOG.error("Error during refactoring", e)
			MessageDialog.openError(Display.current.activeShell, "Error during refactoring", e.message + System.lineSeparator + "See log for details")
		} 
		catch (Exception exc) {
			LOG.error("Error during refactoring", exc)
			MessageDialog.openError(Display.current.activeShell, "Error during refactoring", exc.message + System.lineSeparator + "See log for details")
		}
		null
	}
	
	def updateSelection(XtextEditor editor, List<WExpression> expressions) {
		val firstNode = NodeModelUtils.getNode(expressions.get(0))
		val lastNode = NodeModelUtils.getNode(expressions.get(expressions.size - 1))
		if (firstNode !== null && lastNode !== null) {
			val correctedSelectionOffset = firstNode.offset
			val correctedSelectionLength = lastNode.endOffset - correctedSelectionOffset
			editor.selectAndReveal(correctedSelectionOffset, correctedSelectionLength)
		}
	}
	
}