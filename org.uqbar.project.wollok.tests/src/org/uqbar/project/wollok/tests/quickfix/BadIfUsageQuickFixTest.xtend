package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class BadIfUsageQuickFixTest extends AbstractWollokQuickFixTestCase {
	@Test
	def ifInsteadOfConditionalExpression(){
		val initial = #['''
			class MyClass{
				const a = 1
				method aIsEven() = if (a.even()) true else false
			}
		''']

		val result = #['''
			class MyClass{
				const a = 1
				method aIsEven() = a.even()
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_replace_if_condition_name)
	}

	@Test
	def ifInsteadOfConditionalExpression2(){
		val initial = #['''
			class MyClass{
				const a = 1
				method aIsEven() {
					if (a.even()) return true else return false
				}
			}
		''']

		val result = #['''
			class MyClass{
				const a = 1
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
				const a = 1
				method aIsOdd() = if (a.even()) false else true
			}
		''']

		val result = #['''
			class MyClass{
				const a = 1
				method aIsOdd() = !(a.even())
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_replace_if_condition_name)
	}

	@Test
	def useConditionInsteadOfAReturnInsideAnIfAndAPlainReturn(){
		val initial = #['''
			class MyClass{
				const bul = true
				method test2() {
					if (bul) {
						return true
					}
					return false
				}
			}
		''']

		val result = #['''
			class MyClass{
				const bul = true
				method test2() {
					return bul
					
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_replace_if_condition_name)
	}
	
}