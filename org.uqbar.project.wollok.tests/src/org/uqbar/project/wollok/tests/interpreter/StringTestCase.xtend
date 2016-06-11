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
				const result = "Esto|Es|una|prueba".split("|")
				const comparison = new List()
				comparison.add("Esto")
				comparison.add("Es")
				comparison.add("una")
				comparison.add("prueba")
				(0..3).forEach { i => assert.that(result.get(i) == comparison.get(i)) }
			}
		'''.interpretPropagatingErrors
	}
	
}