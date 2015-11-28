package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import wollok.lib.AssertionException

/**
 * @author tesonep
 */
class TestTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testWithAssertsOk() {
		'''
			object pepita {
				var energia = 0
				method come(cantidad){
					energia = energia + cantidad * 10
				}
				method energia(){
					return energia
				}
			}

			test "pepita" {
				assert.that(pepita.energia() == 0)	
				assert.equals(0, pepita.energia())	
				
				pepita.come(10)
				assert.equals(100, pepita.energia())	
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testWithAssertEqualsWithErrors() {
			'''
				object pepita {
					var energia = 0
					method come(cantidad){
						energia = energia + cantidad * 10
					}
					method energia(){
						return energia
					}
				}

				test "pepita" {
					try {
						assert.equals(7, pepita.energia())
						assert.fail("should have failed")
					}
					catch e {
						assert.equals("Expected [7] but found [0]", e.getMessage())
					} 	
				}
			'''.interpretPropagatingErrors
	}

	@Test(expected = AssertionError)
	def void testWithAssertsWithErrors() {
		'''
			object pepita {
				var energia = 0
				method come(cantidad){
					energia = energia + cantidad * 10
				}
				method energia(){
					return energia
				}
			}

			test pepita {
				tester.assert(7 == pepita.energia())	
			}
		'''.interpretPropagatingErrors
	}
}