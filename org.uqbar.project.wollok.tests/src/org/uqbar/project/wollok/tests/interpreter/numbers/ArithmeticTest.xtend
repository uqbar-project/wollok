package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * @author tesonep
 */
class ArithmeticTest extends AbstractWollokParameterizedInterpreterTest {
	extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	@Parameter(0)
	public String expression
	
	@Parameter(1)
	public Number expectedResult

	@Parameters(name="{0} == {1}")
	static def Iterable<Object[]> data() {
		#[
			// Addition
			#["1 + 1", 2],
			#["1 + 1.5", 2.5],
			#["1.5 + 1", 2.5],
			#["1.3 + 1.7", 3.0],

			// Subtraction
			#["1 - 1", 0],
			#["1 - 1.5", -0.5],
			#["1.5 - 1", 0.5],
			#["1.5 - 1.5", 0.0],

			// Product
			#["1 * 1", 1],
			#["1 * 1.5", 1.5],
			#["1.5 * 1", 1.5],
			#["1.5 * 1.5", 2.25], // TODO Should be #["1.4*1.4", "1.96"], but it does not work

			// Division
			#["3 / 2", 1],
			#["3 / 2.0", 1.5],
			#["3.0 / 2", 1.5],
			#["2.25 / 1.5", 1.5],

			// Exponentiation
			#["3 ** 2", 9],
			#["9 ** 0.5", 3.0],
			#["1.5 ** 2", 2.25],
			#["2.25 ** 0.5", 1.5],
			
			// Module
			#["10 % 3", 1]
		]
	}
	
	@Test
	def void validateResult() { 
		val WollokObject actual = expression.evaluate as WollokObject
		val WollokObject expected = expectedResult.asWollokObject 
		
		try {
			assertTrue(expected.call("==", actual) as Boolean) // should return a WBoolean
		}
		catch (AssertionError e) {
			println("Expected " + expected + " but got " + actual)
			throw e
		}
	}
}