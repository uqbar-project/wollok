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
	def changeDeclarationToVarInInitializeMethodOfATest(){
		val initial = #['''
			describe "some tests" {
				const x = 23
				
				test "x can be 25?" {
					x = 25
					assert.equals(25, x)
				}
			}
		''']

		val result = #['''
			describe "some tests" {
				var x = 23
				
				test "x can be 25?" {
					x = 25
					assert.equals(25, x)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToVar_name)		
	}
	
	@Test
	def testMethodWithExpressionNotReturning(){
		val initial = #['''
			class MyClass{
				const y = 0
				method getX(){
					y + 1
				}
			}
		''']

		val result = #['''
			class MyClass{
				const y = 0
				method getX(){
					return y + 1
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_return_last_expression_name)
	}

}