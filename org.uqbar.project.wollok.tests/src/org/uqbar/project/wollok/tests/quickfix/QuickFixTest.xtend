package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class QuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def changeDeclarationToVar(){
		val initial = #['''
			object myObj{
				method someMethod(){
					const x = 23
					x = 25
				}
			}
		''']

		val result = #['''
			object myObj{
				method someMethod(){
					var x = 23
					x = 25
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToVar_name)		
	}

	@Test
	def changeDeclarationToVarInConstructor(){
		val initial = #['''
			class SomeClass {
				const x
				
				constructor() {
					x = 23
				}
				
				method someMethod(){
					x = 25
				}
			}
		''']

		val result = #['''
			class SomeClass {
				var x
				
				constructor() {
					x = 23
				}
				
				method someMethod(){
					x = 25
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToVar_name)		
	}

	@Test
	def changeDeclarationToVarInFixture(){
		val initial = #['''
			describe "some tests" {
				const x
				
				fixture {
					x = 23
				}
				
				test "x can be 25?" {
					x = 25
				}
			}
		''']

		val result = #['''
			describe "some tests" {
				var x
				
				fixture {
					x = 23
				}
				
				test "x can be 25?" {
					x = 25
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToVar_name)		
	}
	
	@Test
	def testMethodWithExpressionNotReturning(){
		val initial = #['''
			class MyClass{
				var y = 0
				method getX(){
					y + 1
				}
			}
		''']

		val result = #['''
			class MyClass{
				var y = 0
				method getX(){
					return y + 1
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_return_last_expression_name)
	}

	@Test
	def ifInsteadOfConditionalExpression(){
		val initial = #['''
			class MyClass{
				var a = 1
				method aIsEven() = if (a.even()) true else false
			}
		''']

		val result = #['''
			class MyClass{
				var a = 1
				method aIsEven() = a.even()
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_replace_if_condition_name)
	}

	@Test
	def ifInsteadOfConditionalExpression2(){
		val initial = #['''
			class MyClass{
				var a = 1
				method aIsEven() {
					if (a.even()) return true else return false
				}
			}
		''']

		val result = #['''
			class MyClass{
				var a = 1
				method aIsEven() {
					return a.even()
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_replace_if_condition_name)
	}

	@Test
	def ifInsteadOfConditionalExpressionNot(){
		val initial = #['''
			class MyClass{
				var a = 1
				method aIsOdd() = if (a.even()) false else true
			}
		''']

		val result = #['''
			class MyClass{
				var a = 1
				method aIsOdd() = !(a.even())
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_replace_if_condition_name)
	}
	
}