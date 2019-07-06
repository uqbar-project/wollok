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
		const x = "Hola, wollok!".substring(0, 3)
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
		assert.that("aguacate".contains("agua"))
		assert.notThat("aguacate".contains("managua"))
		assert.notThat("aguacate".contains("AGUA"))
		'''.test
	}
	
	@Test
	def void testIndexOf(){
		'''
		assert.equals(0, "aguacate".indexOf("agua"))
		assert.equals(4, "aguacate".indexOf("cat"))
		assert.throwsException( {"aguacate".indexOf("trinitrotolueno")} )
		'''.test
	}

	@Test
	def void testLastIndexOf(){
		'''
		assert.equals(6, "aguacate".lastIndexOf("te"))
		assert.equals(5, "aguacate".lastIndexOf("a"))
		assert.throwsException( {"aguacate".lastIndexOf("trinitrotolueno")} )
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
	
	@Test
	def void words() {
		'''
		const words = "in wollok everything is an object".words()
		assert.equals("in", words.get(0))
		assert.equals("object", words.get(5))
		'''.test
	}
	
	@Test
	def void capitalize() {
		'''
		assert.equals("alfa romeo".capitalize(), "Alfa Romeo")
		assert.equals("AUDI".capitalize(), "Audi")
		assert.equals("bmw".capitalize(), "Bmw")
		assert.equals("ONETWO THREE FOUR".capitalize(), "Onetwo Three Four")
		'''.test
	}

	@Test
	def void printString() {
		'''
		assert.equals("hola".printString(), "\"hola\"")
		assert.equals("3".printString(), "\"3\"")
		'''.test
	}

	@Test
	def void charAtUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation charAt doesn't support null parameters", { "hola".charAt(null) })
		'''.test
	}
	
	@Test
	def void charAtFail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { "hola".charAt("a") })
		'''.test
	}
	
	@Test
	def void charAt() {
		'''
		assert.equals("l", "hola".charAt(2))
		'''.test
	}
	
	@Test
	def void reverse() { 
		'''
		assert.equals("aloh", "hola".reverse())
		assert.equals("", "".reverse())
		'''.test
	}
	
	@Test
	def void left() { 
		'''
		assert.equals("hol", "hola".left(3))
		assert.equals("", "".left(3))
		assert.equals("", "hola".left(0))
		assert.equals("h", "hola".left(1.5))
		'''.test
	}
	
	@Test
	def void leftFail() { 
		'''
		assert.throwsExceptionWithMessage("-1.00000 must be a positive integer value", { "hola".left(-1) })
		'''.test
	}

	@Test
	def void startsWithUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation startsWith doesn't support null parameters", { "hola".startsWith(null) })
		'''.test
	}
	
	@Test
	def void startsWithFail() {
		'''
		assert.throwsExceptionWithMessage("Operation doesn't support parameter a Date[day = 1, month = 1, year = 2018]", { "hola".startsWith(new Date(1, 1, 2018)) })
		'''.test
	}
	
	@Test
	def void startsWith() {
		'''
		assert.that("hola".startsWith("ho"))
		'''.test
	}

	@Test
	def void endsWithUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation endsWith doesn't support null parameters", { "hola".endsWith(null) })
		'''.test
	}
	
	@Test
	def void endsWithFail() {
		'''
		assert.throwsExceptionWithMessage("Operation doesn't support parameter a Date[day = 1, month = 1, year = 2018]", { "hola".endsWith(new Date(1, 1, 2018)) })
		'''.test
	}
	
	@Test
	def void endsWith() {
		'''
		assert.that("hola".endsWith("la"))
		'''.test
	}

	@Test
	def void indexOfUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation indexOf doesn't support null parameters", { "hola".indexOf(null) })
		'''.test
	}
	
	@Test
	def void indexOfFail() {
		'''
		assert.throwsExceptionWithMessage("Operation doesn't support parameter a Date[day = 1, month = 1, year = 2018]", { "hola".indexOf(new Date(1, 1, 2018)) })
		'''.test
	}

	@Test
	def void lastIndexOfUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation lastIndexOf doesn't support null parameters", { "hola".lastIndexOf(null) })
		'''.test
	}
	
	@Test
	def void lastIndexOfFail() {
		'''
		assert.throwsExceptionWithMessage("Operation doesn't support parameter a Date[day = 1, month = 1, year = 2018]", { "hola".lastIndexOf(new Date(1, 1, 2018)) })
		'''.test
	}

	@Test
	def void containsUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation contains doesn't support null parameters", { "hola".contains(null) })
		'''.test
	}
	
	@Test
	def void containsFail() {
		'''
		assert.throwsExceptionWithMessage("Operation doesn't support parameter a Date[day = 1, month = 1, year = 2018]", { "hola".contains(new Date(1, 1, 2018)) })
		'''.test
	}

	@Test
	def void substring2UsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation substring doesn't support null parameters", { "hola".substring(null, null) })
		'''.test
	}
	
	@Test
	def void substring2Fail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { "hola".substring("a", "e") })
		'''.test
	}

	@Test
	def void substring1UsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation substring doesn't support null parameters", { "hola".substring(null) })
		'''.test
	}
	
	@Test
	def void substring1Fail() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter \"a\" to type wollok.lang.Number", { "hola".substring("a") })
		'''.test
	}
	
	@Test
	def void equalsIgnoreCaseNull() {
		'''
		assert.throwsExceptionWithMessage("Reference aString is not initialized", { "hola".equalsIgnoreCase(null) })
		'''.test
	}
	
	@Test
	def void equalsIgnoreCaseFail() {
		'''
		assert.throwsExceptionWithMessage("a Date[day = 1, month = 1, year = 2018] does not understand toUpperCase()", { "hola".equalsIgnoreCase(new Date(1, 1, 2018)) })
		'''.test
	}

	@Test
	def void replaceUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation replace doesn't support null parameters", { "hola".replace("1", null) })
		assert.throwsExceptionWithMessage("Operation replace doesn't support null parameters", { "hola".replace(null, "2") })
		'''.test
	}
	
	@Test
	def void replaceFail() {
		'''
		assert.throwsExceptionWithMessage("Operation doesn't support parameter a Date[day = 1, month = 1, year = 2018], a", { "hola".replace(new Date(1, 1, 2018), "a") })
		'''.test
	}

}
