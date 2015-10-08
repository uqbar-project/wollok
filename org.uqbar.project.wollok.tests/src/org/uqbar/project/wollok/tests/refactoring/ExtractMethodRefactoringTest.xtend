package org.uqbar.project.wollok.tests.refactoring

import com.google.inject.Inject
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.ltk.core.refactoring.RefactoringStatus
import org.eclipse.ui.IWorkbenchPartSite
import org.eclipse.ui.texteditor.IDocumentProvider
import org.eclipse.xtext.resource.DefaultLocationInFileProvider
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.DocumentTokenSource
import org.eclipse.xtext.ui.editor.model.XtextDocument
import org.eclipse.xtext.ui.editor.model.edit.ITextEditComposer
import org.eclipse.xtext.ui.refactoring.impl.ProjectUtil
import org.eclipse.xtext.ui.refactoring.impl.StatusWrapper
import org.eclipse.xtext.xbase.ui.document.DocumentRewriter
import org.eclipse.xtext.xbase.ui.imports.ReplaceConverter
import org.eclipse.xtext.xbase.ui.refactoring.ExpressionUtil
import org.junit.Test
import org.uqbar.project.wollok.refactoring.ExtractMethodRefactoring
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.xpect.util.ReflectionUtil

import static org.mockito.Matchers.*
import static org.mockito.Mockito.*
import org.eclipse.emf.common.util.TreeIterator
import org.eclipse.emf.ecore.EObject

/**
 * 
 * @author jfernandes
 */
class ExtractMethodRefactoringTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void extractSimpleMethodWithoutParametersReturningAValue() {
		assertRefactor('''
			class A {
				method foo() {
					return 100 + 23 * 2
				}
			}
		''',
		"calculus",
		[filter(WBinaryOperation).findFirst[e | e.feature == "*"] as WExpression],
		'''
			class A {
				method foo() {
					return 100 + this.calculus()
				}
				
				method calculus() {
					return 23 * 2
				}
			}
		''')
	}
	
	@Test
	def void extractMethodReferencingParameter() {
		assertRefactor('''
			class A {
				method foo(bar) {
					return 100 + bar * 2
				}
			}
		''',
		"calculus",
		[filter(WBinaryOperation).findFirst[e | e.feature == "*"] as WExpression],
		'''
			class A {
				method foo(bar) {
					return 100 + this.calculus(bar)
				}
				
				method calculus(bar) {
					return bar * 2
				}
			}
		''')
	}
	
	// *****************************
	// ** utility methods
	// *****************************
	
	@Inject DocumentRewriter.Factory rProvider
	@Inject DocumentTokenSource tokenSource
	@Inject ITextEditComposer composer
	
	def void assertRefactor(String code, String newMethodName,(TreeIterator<EObject>)=>WExpression selector, String refactored) {
		
		val editor = createEditor(code)
		
		val selection = selector.apply(code.interpretPropagatingErrors.eAllContents)
		
		val ExtractMethodRefactoring r = createRefactoring(newMethodName)
		r.initialize(editor, #[selection], false)
		
		val pm = new NullProgressMonitor 
		
		// checks		
		assertEquals(#[].toString, r.checkInitialConditions(pm).entries.toString)
		assertEquals(#[].toString, r.checkFinalConditions(pm).entries.toString)

		// perform
		val change = r.createChange(pm)
		change.perform(pm)
		
		// assert
		val output = editor.document.get
		assertEquals(refactored, output)
	}
	
	def createRefactoring(String newMethodName) {
		val fileProvider = new DefaultLocationInFileProvider
		new ExtractMethodRefactoring => [
			methodName = newMethodName
			statusProvider = [| new StatusWrapper => [
				forceField("status", new RefactoringStatus)
				forceField("projectUtil", mock(ProjectUtil))
				forceField("locationInFileProvider", fileProvider)
			]]
			expressionUtil = new ExpressionUtil => [
				forceField("locationInFileProvider", fileProvider)
			]
			rewriterFactory = rProvider
			locationInFileProvider = fileProvider
			replaceConverter = new ReplaceConverter
		]
	}
	
	def forceField(Object obj, String field, Object value) {
		ReflectionUtil.writeField(obj.class, obj, field, value)
	}
	
	def createEditor(String code) {
		val xtexdoc = new XtextDocument(tokenSource, composer)
		xtexdoc.set(code)
		
		val provider = mock(IDocumentProvider) => [
			when(getDocument(any)).thenReturn(xtexdoc)			
		]
		
		mock(XtextEditor) => [
			when(documentProvider).thenReturn(provider)
			when(document).thenReturn(xtexdoc)
			when(editorInput).thenReturn(null)
			when(site).thenReturn(mock(IWorkbenchPartSite))			
		]
	}

}