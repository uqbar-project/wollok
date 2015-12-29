package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

class NumberExtensionsTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String expression
	
	@Parameter(1)
	public String expectedResult

	@Parameters(name="{0} == {1}")
	static def Iterable<Object[]> data() {
		#[
			// Max
			#["1.max(2)", "2"],
			#["(1.0).max(2)", "2"],
			#["1.max(2.0)", "2.0"],
			#["(1.0).max(2.0)", "2.0"],

			#["2.max(1)", "2"],
			#["(2.0).max(1)", "2.0"],
			#["2.max(1.0)", "2"],
			#["(2.0).max(1.0)", "2.0"],

			// Min
			#["1.min(2)", "1"],
			#["(1.0).min(2)", "1.0"],
			#["1.min(2.0)", "1"],
			#["(1.0).min(2.0)", "1.0"],

			#["2.min(1)", "1"],
			#["(2.0).min(1)", "1"],
			#["2.min(1.0)", "1.0"],
			#["(2.0).min(1.0)", "1.0"],

			// Abs
			#["1.abs()", "1"],
			#["(-1).abs()", "1"],
			#["(1.0).abs()", "1.0"],
			#["(-1.0).abs()", "1.0"],
			
			// LimitBetween
			#["1.limitBetween(2,3)", "2"],
			#["(1.0).limitBetween(2,3)", "2"],
			#["1.limitBetween(2.0,3)", "2.0"],
			#["(1.0).limitBetween(2.0,3)", "2.0"],

			#["4.limitBetween(2,3)", "3"],
			#["(4.0).limitBetween(2,3)", "3"],
			#["4.limitBetween(2,3.0)", "3.0"],
			#["(4.0).limitBetween(2,3.0)", "3.0"],
			
			#["4.limitBetween(2,10)", "4"],
			#["(4.0).limitBetween(2,10)", "4.0"],
			
			#["1.limitBetween(3,2)", "2"],
			#["(1.0).limitBetween(3,2)", "2"],
			#["1.limitBetween(3,2.0)", "2.0"],
			#["(1.0).limitBetween(3,2.0)", "2.0"],

			#["4.limitBetween(3,2)", "3"],
			#["(4.0).limitBetween(3,2)", "3"],
			#["4.limitBetween(3.0,2)", "3.0"],
			#["(4.0).limitBetween(3.0,2)", "3.0"],
			
			#["4.limitBetween(10,2)", "4"],
			#["(4.0).limitBetween(10,2)", "4.0"]
		]
	}
	
	@Test
	def void runAssertion() { assertion.interpretPropagatingErrors }

	def assertion() '''
		program p {
			assert.equals(«expectedResult», «expression») 
		}
	'''
}