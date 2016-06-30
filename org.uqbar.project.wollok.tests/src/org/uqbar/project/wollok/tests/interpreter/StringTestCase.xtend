package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author tesonep
 */
class StringTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testWithAssertsOk() {
		'''
			test "pepita" {
				const x = "Hola, wollok!".substring(0,3)
				assert.equals("Hol", x)			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testLessThan() {
		'''program a {
				assert.that("miau" < "ufa")			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testLessThanFalseCondition() {
		'''program a {
				assert.notThat("zapallo" <= "ufa")			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testGreaterOrEqualThan() {
		'''program a {
				assert.that("zapallo" >= "ufa")
				assert.that("zapallo" >= "zapallo")
				assert.notThat("aguacero" >= "guarecer")			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testLessOrEqualThanForLess() {
		'''program a {
				assert.that("miau" <= "ufa")			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testLessOrEqualThanForEqual() {
		'''program a {
				assert.that("miau" <= "miau")			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testContains() {
		'''program a {
				assert.that("aguacate".contains("cat"))
				assert.notThat("aguacate".contains("managua"))			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testisEmpty() {
		'''program a {
				assert.that("".isEmpty())			
				assert.notThat("pepe".isEmpty())
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testEqualEqual() {
		'''program a {
				const unString = "perro"
				const otroString = "per" + "ro"
				assert.that(unString == otroString)			
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testEqualsIgnoreCase() {
		'''program a {
				assert.that("mARejaDA".equalsIgnoreCase("MAREJADA"))			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testSplit() {
		'''program a {
				const result = "Esto Es una prueba".split(" ")
				const result2 = "Esto|Es|una|prueba".split("|")
				const result3 = "Esto,Es,una,prueba".split(",")
				const comparison = ["Esto", "Es", "una", "prueba"]
				(0..3).forEach { i => assert.that(result.get(i) == comparison.get(i)) }
				(0..3).forEach { i => assert.that(result2.get(i) == comparison.get(i)) }
				(0..3).forEach { i => assert.that(result3.get(i) == comparison.get(i)) }
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testReplace() {
		'''program a {
				const mardel = "Mar del Plata"
				const tuyu = mardel.replace("Plata", "Tuyu")
				assert.that("Mar del Tuyu" == tuyu)			
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void randomForStringsAreNotAllowedAnymore() {
		'''program a {
			assert.throwsException({ => "fafafa".randomUpTo(8.9)})
		}
		'''.interpretPropagatingErrors
	}	
	
}