package org.uqbar.project.wollok.tests.refactoring

import com.google.inject.Inject
import java.util.List
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.common.util.TreeIterator
import org.eclipse.emf.ecore.EObject
import org.eclipse.ltk.core.refactoring.RefactoringStatus
import org.eclipse.ui.IWorkbenchPartSite
import org.eclipse.ui.texteditor.IDocumentProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
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
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.xpect.util.ReflectionUtil

import static org.mockito.Matchers.*
import static org.mockito.Mockito.*

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
					return 100 + /* */ 23 * 2 /* */
				}
			}
		''',
		"calculus",
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
					return 100 + /* */ bar * 2 /* */
				}
			}
		''',
		"calculus",
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
	
	@Test
	def void extractMethodWithoutReturn() {
		assertRefactor('''
			class A {
				method foo(bar) {
					console.println("hola mundo")
					return 100 + bar * 2
				}
			}
		''',
		"imprimir",
		[filter(WMemberFeatureCall).filter[e | e.feature == "println"].filter(WExpression).toList],
		'''
			class A {
				method foo(bar) {
					this.imprimir()
					return 100 + bar * 2
				}
				
				method imprimir() {
					console.println("hola mundo")
				}
			}
		''')
	}
	
	@Test
	def void extractMethodReferencingInstanceVariable() {
		assertRefactor('''
			class A {
				var bar = 20
				method foo() {
					return 100 + /* */ bar * 2 /* */
				}
			}
		''',
		"calculus",
		'''
			class A {
				var bar = 20
				method foo() {
					return 100 + this.calculus()
				}
				
				method calculus() {
					return bar * 2
				}
			}
		''')
	}
	
	@Test
	def void extractMethodReferencingTwoMixedVariables() {
		assertRefactor('''
			class A {
				var bar = 20
				method foo(zoo) {
					return 100 + /* */ bar * 2 * zoo /* */
				}
			}
		''',
		"calculus",
		'''
			class A {
				var bar = 20
				method foo(zoo) {
					return 100 + this.calculus(zoo)
				}
	
				method calculus(zoo) {
					return bar * 2 * zoo
				}
			}
		''')
	}
	
	@Test
	def void extractReturnStatement() {
		assertRefactor('''
			class A {
				method foo() {
					val tempVal = 2
					return 100 + 2 * tempVal
				}
			}
		''',
		"calculus",
		[filter(WReturnExpression).filter(WExpression).toList],
		'''
			class A {
				method foo() {
					val tempVal = 2
					return this.calculus()
				}
	
				method calculus() {
					return 100 + 2 * tempVal
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
	
	def void assertRefactor(String code, String newMethodName, String refactored) {
		val start = code.indexOf('/* */')
		val end = code.lastIndexOf('/* */')
		
		assertRefactor(code, newMethodName, [
			it.filter[e| NodeModelUtils.getNode(e).offset >= start && NodeModelUtils.getNode(e).offset + NodeModelUtils.getNode(e).length <= end ]
			.filter(WExpression).toList
		], refactored)
	}
	
	def void assertRefactor(String code, String newMethodName,(TreeIterator<EObject>)=>List<WExpression> selector, String refactored) {
		
		val editor = createEditor(code)
		
		val selection = selector.apply(code.interpretPropagatingErrors.eAllContents)
		
		val ExtractMethodRefactoring r = createRefactoring(newMethodName)
		r.initialize(editor, selection, false)
		
		val pm = new NullProgressMonitor 
		
		// checks		
		assertEquals(#[].toString, r.checkInitialConditions(pm).entries.toString)
		assertEquals(#[].toString, r.checkFinalConditions(pm).entries.toString)

		// perform
		val change = r.createChange(pm)
		change.perform(pm)
		
		// assert
		val output = editor.document.get.replaceAll(' \\/\\* \\*\\/', '')
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