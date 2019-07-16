package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * Test type inference in if expressions
 * 
 * @author jfernandes
 * @author npasserini
 */
class IfTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
		]
	}

	@Test
	def void testIfBranchesInferredFromOutside() {
		''' 
			program p {
				var a
				var b
				var number = 23
				number = if (true) a else b 
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "a")
			assertTypeOf(classTypeFor(NUMBER), "b")
		]
	}

	@Test
	def void testInferTHENFromELSE() {
		''' 
			program p {
				const a
				const number = if (true) a else 23
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "a")
		]
	}

	@Test
	def void testInferELSEFromTHEN() {
		'''
			program p {
				const a
				const number = if (true) 23 else a
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "a")
		]
	}

	@Test
	def void ifConditionMustBeBoolean() {
		'''
			program p {
				const n = 23
				const number = if (n) 2 else 6
			}
		'''.parseAndInfer.asserting [
			findByText("n", WVariableReference).assertIssuesInElement("expected <<Boolean>> but found <<Number>>")
		]
	}

	@Test
	def void ifConditionMustBeBooleanWithIntermediateAssignment() {
		'''
			program p {
				const n = 23
				const p = n
				const number = if (p) 2 else 6
			}
		'''.parseAndInfer.asserting [
			findByText("p", WVariableReference).assertIssuesInElement("expected <<Boolean>> but found <<Number>>")
		]
	}

	@Test
	def void ifConditionMustBeBooleanWithUnimportantNoise() {
		'''
			program p {
				const n = 23
				const p = n
				const number = if (n) 2 else 6
			}
		'''.parseAndInfer.asserting [
			findAllByText("n", WVariableReference).get(1).assertIssuesInElement(
				"expected <<Boolean>> but found <<Number>>")
		]
	}
}
