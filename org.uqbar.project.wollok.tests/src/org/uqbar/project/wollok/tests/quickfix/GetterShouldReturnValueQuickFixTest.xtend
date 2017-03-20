package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class GetterShouldReturnValueQuickFixTest extends AbstractWollokQuickFixTestCase {
	@Test
	def testGetterWithoutBodyAndExistentVariable(){
		val initial = #['''
			class MyClass{
				var x = 23
				method getX(){
				}
				
				method setX(obj){
					x = obj
				}
			}
		''']

		val result = #['''
			class MyClass{
				var x = 23
				method getX(){
					return x
				}
				
				method setX(obj){
					x = obj
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_return_variable_name)
	}
	
	
	@Test
	def testGetterWithBodyAndExistentVariable(){
		val initial = #['''
			class MyClass{
				var x = 23
				var y = 0
				method getX(){
					y = y + 1
				}
				
				method setX(obj){
					x = obj
				}
			}
		''']

		val result = #['''
			class MyClass{
				var x = 23
				var y = 0
				method getX(){
					y = y + 1
					return x
				}
				
				method setX(obj){
					x = obj
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_return_variable_name)
	}

	@Test
	def testGetterMissingReturn(){
		val initial = #['''
			class MyClass{
				var y = 0
				method getX(){
					y + 1
				}
				
				method setY(obj){
					y = obj
				}
			}
		''']

		val result = #['''
			class MyClass{
				var y = 0
				method getX(){
					return 
					y + 1
				}
				
				method setY(obj){
					y = obj
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_return_last_expression_name)
	}

	@Test
	def testGetterMissingReturnWithCall(){
		val initial = #['''
			class MyClass{
				method getX(){
					self.doSomething()
					self.doSomething()
				}
				
				method doSomething(){
					return 1
				}
			}
		''']

		val result = #['''
			class MyClass{
				method getX(){
					self.doSomething()
					return 
					self.doSomething()
				}
				
				method doSomething(){
					return 1
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_return_last_expression_name)
	}

}