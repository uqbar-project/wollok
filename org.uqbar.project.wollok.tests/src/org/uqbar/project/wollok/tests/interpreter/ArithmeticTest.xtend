package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

class ArithmeticTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String expression
	
	@Parameter(1)
	public String expectedResult

	@Parameters(name="{0} == {1}")
	static def Iterable<Object[]> data() {
		#[
			// Addition
			#["1 + 1", "2"],
			#["1 + 1.5", "2.5"],
			#["1.5 + 1", "2.5"],
			#["1.3 + 1.7", "3.0"],

			// Subtraction
			#["1 - 1", "0"],
			#["2 - 1.5", "0.5"], // TODO -0.5 cannot be parsed
			#["1.5 - 1", "0.5"],
			#["1.5 - 1.5", "0.0"],

			// Product
			#["1 * 1", "1"],
			#["1 * 1.5", "1.5"],
			#["1.5 * 1", "1.5"],
			#["1.5 * 1.5", "2.25"], // TODO Should be #["1.4*1.4", "1.96"], but it does not work

			// Division
			#["3 / 2", "1"],
			#["3 / 2.0", "1.5"],
			#["3.0 / 2", "1.5"],
			#["2.25 / 1.5", "1.5"],

			// Exponentiation
			#["3 ** 2", "9"],
			#["9 ** 0.5", "3.0"],
			#["1.5 ** 2", "2.25"],
			#["2.25 ** 0.5", "1.5"],
			
			// Module
			#["10 % 3", "1"]
		]
	}
	
	@Test
	def void runAssertion() { assertion.interpretPropagatingErrors }

	def assertion() '''
		program p {
			this.assertEquals(«expectedResult», «expression») 
		}
	'''
}