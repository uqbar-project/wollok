package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * @author tesonep
 * @author jfernades
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

			program p {
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

				program pepitao {
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

			program p {
				tester.assert(7 == pepita.energia())	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test(expected = AssertionError)
	def void testWithExpectedExceptionWithErrors() {
		'''
			program p {
				assert.throwsException { 4 }	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testWithExpectedExceptionWithoutErrors() {
		'''
			program p {
				assert.throwsException { 
					val x = null
					x.foo()
				}	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testsAreIsolatedInTermsOfStateWKO() {
		'''
		   object globalin {
		   	    var a = 10
		   	    method a(nuevo) { a = nuevo }
		   	    method a() = a
		   }
		   test "Changing a to 20" {
				assert.equals(10, globalin.a())
		   	    globalin.a(20)
		   	    assert.equals(20, globalin.a())
		   }
		   test "Is back in 10 and change it to 30" {
		   	    // starts with 10 again !
		   		assert.equals(10, globalin.a())
		   	    globalin.a(30)
		   	    assert.equals(30, globalin.a())
		   }
		   test "Changing a to 10" {
   		   	    // starts with 10 again !
   		   		assert.equals(10, globalin.a())
   		   }
		'''.interpretPropagatingErrors
	}
	
}