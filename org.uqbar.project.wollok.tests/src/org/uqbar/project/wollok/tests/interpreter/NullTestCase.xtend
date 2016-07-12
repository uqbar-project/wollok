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
					assert.equals(msg, e.getCause().getMessage())
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
			extendedAssert.assertException({ null.sayHi() }, "Cannot send message sayHi() to null")
			extendedAssert.assertException({ null.toString() }, "Cannot send message toString() to null")
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void numberOperatorsSentToNull() {
		'''
		«defineAssertWithMessage»
		program a {
			extendedAssert.assertException({ null + 3 }, "Cannot send message + to null")
			extendedAssert.assertException({ null - 3 }, "Cannot send message - to null")
			extendedAssert.assertException({ null * 3 }, "Cannot send message * to null")
			extendedAssert.assertException({ null / 3 }, "Cannot send message / to null")
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void booleanOperatorsSentToNull() {
		'''
		«defineAssertWithMessage»
		program a {
			extendedAssert.assertException({ null || null }, "Cannot send message || to null")
			extendedAssert.assertException({ null && null }, "Cannot send message && to null")
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void equalEqualOperatorSentToNull() {
		'''
		class Golondrina { var energia = 0 }
		
		program a {
			var valorNulo
			assert.notThat(null == 8)
			assert.notThat(null == "pepe")
			assert.notThat(null == 3.0)
			assert.notThat(null == 1..2)
			assert.notThat(null == [1,2,3])
			assert.notThat(null == #{1,2,3})
			assert.notThat(null == assert)
			assert.notThat(null == new Golondrina())
			assert.notThat(valorNulo == 8)
			assert.that(valorNulo == null)
			assert.notThat(valorNulo != null)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void equalEqualOperatorWithANullArgument() {
		'''
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
		'''.interpretPropagatingErrors
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
		assert.equals("Cannot use null in 'if' condition", mensajeError)
		'''.test
	}
	
}