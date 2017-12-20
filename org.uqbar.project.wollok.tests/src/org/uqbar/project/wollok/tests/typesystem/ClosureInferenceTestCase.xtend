package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

/**
 * Test cases for type inference of closures.
 * 
 * @author jfernandes
 */
class ClosureInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Object[] typeSystems() {
		#[
//			SubstitutionBasedTypeSystem,
//			,XSemanticsTypeSystem
			ConstraintBasedTypeSystem
//			,BoundsBasedTypeSystem    
		]
	}

	@Test
	def void closureNoArgsReturnsStringLiteral() {
		'''
			program p {
				const c = { "Hello" }
			}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("() => String", "c")
		]
	}

	@Test
	def void closureWithMathOperation() {
		'''
			program p {
				const c = { a => 2 + a }
			}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("(Number) => Number", "c")
		]
	}

	@Test
	def void emptyClosure() {
		'''
			program p {
				const c = { }
			}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("() => Void", "c")
		]
	}

	@Test
	def void returnClosure() {
		'''
			program p {
				const c = { return true }
			}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("() => Boolean", "c")
		]
	}
}
