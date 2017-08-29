package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class NullTestCase extends AbstractWollokInterpreterTestCase {
	
	def defineAssertWithMessage() {
		'''
		object extendedAssert {
			method assertException(closure, msg) {
				try {
					closure.apply()
				} catch e: Exception {
					var message = e.getMessage()
					if (e.getCause() != null) {
						message = e.getCause().getMessage()
					}
					assert.equals(msg, message)
				}
			}
		}
		'''
	}
	
	@Test
	def void messageSentToNull() {
		'''
		«defineAssertWithMessage»
		program a {
			extendedAssert.assertException({ null.sayHi() }, "Wrong message sayHi() sent to null")
			extendedAssert.assertException({ null.toString() }, "Wrong message toString() sent to null")
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void numberOperatorsSentToNull() {
		'''
		«defineAssertWithMessage»
		program a {
			extendedAssert.assertException({ null + 3 }, "Wrong message + sent to null")
			extendedAssert.assertException({ null - 3 }, "Wrong message - sent to null")
			extendedAssert.assertException({ null * 3 }, "Wrong message * sent to null")
			extendedAssert.assertException({ null / 3 }, "Wrong message / sent to null")
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void booleanOperatorsSentToNull() {
		'''
		«defineAssertWithMessage»
		program a {
			extendedAssert.assertException({ null || null }, "Wrong message || sent to null")
			extendedAssert.assertException({ null && null }, "Wrong message && sent to null")
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}
	
	@Test
	def void equalEqualOperatorSentToNull() {
		'''
		class Golondrina { var energia = 0 }
		
		program a {
			var valorNulo
			//Just to check if the null can be tested against a WKO
			//Cannot be performed directly because you should not use comparison over WKO
			var x = assert
			
			assert.notThat(null == 8)
			assert.notThat(null == "pepe")
			assert.notThat(null == 3.0)
			assert.notThat(null == 1..2)
			assert.notThat(null == [1,2,3])
			assert.notThat(null == #{1,2,3})
			assert.notThat(null == x)
			assert.notThat(null == new Golondrina())
			assert.notThat(valorNulo == 8)
			assert.that(valorNulo == null)
			assert.notThat(valorNulo != null)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void equalEqualOperatorWithANullArgument() {
		interpretPropagatingErrorsWithoutStaticChecks('''
		class Golondrina { var energia = 0 }
		
		program a {
			assert.notThat(8 == null)
			assert.notThat("pepe" == null)
			assert.notThat(false == null)
			assert.notThat(2.0 == null)
			assert.notThat(1..2 == null)
			assert.notThat([1,2,3] == null)
			assert.notThat(#{1,2,3} == null)
			assert.notThat(assert == null)
			assert.notThat(new Golondrina() == null)
		}
		''')
	}
	
	@Test
	def void ifInANullExpression() {
		'''
		var expresionNula
		var mensajeError
		try {
			if (expresionNula) {
				assert.fail("Null Expression didn't fail!")
			}
		} catch e: Exception {
			mensajeError = e.getMessage()
		}
		assert.equals("Cannot use null in 'if' expression", mensajeError)
		'''.test
	}

	@Test
	def void nullInAOpMultiAndPostFix() {
		
		'''
		«definePepitaAndAlpiste»
		program a {
			assert.throwsException({ pepita.comer(alpiste)})
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void nullInAOpMultiAndPostFix2() {
		
		'''
		«definePepitaAndAlpiste»
		program a {
			assert.throwsException({ pepita.volar(10)})
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void checkNullByIdentity(){
		'''
		program a {
			var a = null
			assert.that(a == null)
			assert.notThat(a != null)
			assert.that(a === null)
			assert.notThat(a !== null)			
			assert.notThat(1 === null)
			assert.that(1 !== null)			
		
			assert.notThat(1 === 2)
			assert.that(1 !== 2)						
		}
		'''.interpretPropagatingErrors
	}

	private def String definePepitaAndAlpiste() {
		'''
		object pepita {
		    var energia
		    method energia() { return energia }
		
		    method volar(metros) { energia -= metros * 10 }
		    method comer(comida) { 
		        energia += comida.energia()
		    }
		}

		object alpiste {
			method energia() = 2	
		}
		'''
	}	
}