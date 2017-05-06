package org.uqbar.project.wollok.tests.quickfix

import org.junit.Ignore
import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

/**
 * author dodain
 * For now this tests are ignored since I replaced a simple rename by a full refactor of abstractions
 * This means you need to use EditorUtils.getActiveEditor() , so you need to have a UI (and it is not easy to mock)
 */
class CapitalizationQuickFixTest extends AbstractWollokQuickFixTestCase {
	@Test
	def testCapitalizeClassName(){
		val initial = #['''
			class myClass{
				method someMethod(){ return "yes" }
			}
		''']

		val result = #['''
			class MyClass{
				method someMethod(){ return "yes" }
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_capitalize_name)
	}
	
	@Test
	def testLowercaseObjectNameSimple(){
		val initial = #['''
			object Pepita {
				method someMethod() { return "yes" }
			}
		''']

		val result = #['''
			object pepita {
				method someMethod() { return "yes" }
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_lowercase_name)
	}

	@Test
	@Ignore
	def testLowercaseObjectNameReferencedByAnotherObject(){
		val initial = #['''
			object Pepita {
				method someMethod() { return "yes" }
			}
			object juan {
				method jugar() { return Pepita.someMethod() }
			}
		''']

		val result = #['''
			object pepita {
				method someMethod() { return "yes" }
			}
			object juan {
				method jugar() { return pepita.someMethod() }
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_lowercase_name)
	}

	@Test
	def testLowercaseVariableName(){
		val initial = #['''
			object pepita {
				var Energia = 100
				method Energia() { return Energia }
				method Energia(_energia) { Energia = _energia }
			}
		''']

		val result = #['''
			object pepita {
				var energia = 100
				method Energia() { return energia }
				method Energia(_energia) { energia = _energia }
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_lowercase_name)
	}

	@Test
	def testLowercaseVariableNameNotParameterWithSameName(){
		val initial = #['''
			object pepita {
				var Energia = 100
				method Energia() { return Energia }
				method Energia(_energia) { Energia = _energia }
				method atolondrarse(Energia) { return Energia * 2 }
			}
		''']

		val result = #['''
			object pepita {
				var energia = 100
				method Energia() { return energia }
				method Energia(_energia) { energia = _energia }
				method atolondrarse(Energia) { return Energia * 2 }
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_lowercase_name, 3)
	}

	@Test
	def testLowercaseParameterName(){
		val initial = #['''
			object pepita {
				var energia = 100
				method volar(Tiempo) { energia -= Tiempo * 2 }
			}
		''']

		val result = #['''
			object pepita {
				var energia = 100
				method volar(tiempo) { energia -= Tiempo * 2 }
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_lowercase_name)
	}
}