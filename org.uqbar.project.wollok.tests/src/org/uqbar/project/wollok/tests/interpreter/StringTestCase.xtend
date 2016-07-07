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
		const x = "Hola, wollok!".substring(0,3)
		assert.equals("Hol", x)			
		'''.test
	}

	@Test
	def void testLessThan() {
		'''
		assert.that("miau" < "ufa")			
		'''.test
	}

	@Test
	def void testLessThanFalseCondition() {
		'''
		assert.notThat("zapallo" <= "ufa")			
		'''.test
	}

	@Test
	def void testGreaterOrEqualThan() {
		'''
		assert.that("zapallo" >= "ufa")
		assert.that("zapallo" >= "zapallo")
		assert.notThat("aguacero" >= "guarecer")			
		'''.test
	}

	@Test
	def void testLessOrEqualThanForLess() {
		'''
		assert.that("miau" <= "ufa")			
		'''.test
	}

	@Test
	def void testLessOrEqualThanForEqual() {
		'''
		assert.that("miau" <= "miau")			
		'''.test
	}

	@Test
	def void testContains() {
		'''
		assert.that("aguacate".contains("cat"))
		assert.notThat("aguacate".contains("managua"))			
		'''.test
	}

	@Test
	def void testisEmpty() {
		'''
		assert.that("".isEmpty())			
		assert.notThat("pepe".isEmpty())
		'''.test
	}

	@Test
	def void testEqualEqual() {
		'''
		const unString = "perro"
		const otroString = "per" + "ro"
		assert.that(unString == otroString)			
		'''.test
	}
	
	@Test
	def void testEqualsIgnoreCase() {
		'''
		assert.that("mARejaDA".equalsIgnoreCase("MAREJADA"))			
		'''.test
	}

	@Test
	def void testSplit() {
		'''
		const result = "Esto Es una prueba".split(" ")
		const result2 = "Esto|Es|una|prueba".split("|")
		const result3 = "Esto,Es,una,prueba".split(",")
		const comparison = ["Esto", "Es", "una", "prueba"]
		(0..3).forEach { i => assert.that(result.get(i) == comparison.get(i)) }
		(0..3).forEach { i => assert.that(result2.get(i) == comparison.get(i)) }
		(0..3).forEach { i => assert.that(result3.get(i) == comparison.get(i)) }
		'''.test
	}

	@Test
	def void testReplace() {
		'''
		const mardel = "Mar del Plata"
		const tuyu = mardel.replace("Plata", "Tuyu")
		assert.that("Mar del Tuyu" == tuyu)			
		'''.test
	}

	@Test
	def void randomForStringsAreNotAllowedAnymore() {
		'''
		assert.throwsException({ => "fafafa".randomUpTo(8.9)})
		'''.test
	}	

	@Test
	def void take() {
		'''
		assert.equals("cl", "clearly".take(2))
		assert.equals("clearly", "clearly".take(8))
		assert.equals("", "clearly".take(0))
		'''.test
	}
	
	@Test
	def void drop() {
		'''
		assert.equals("early", "clearly".drop(2))
		assert.equals("", "clearly".drop(8))
		assert.equals("clearly", "clearly".drop(0))
		'''.test
	}	
}