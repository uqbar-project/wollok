package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem
import org.uqbar.project.wollok.wollokDsl.WVariableReference

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
			SubstitutionBasedTypeSystem,
//			XSemanticsTypeSystem			// TODO 
			ConstraintBasedTypeSystem
//			BoundsBasedTypeSystem,    TO BE FIXED
		]
	}

//	@Test
//	def void testIfBranchesInferredFromOutside() {
//		''' 
//		program p {
//			var a
//			var b
//			var number = 23
//			number = if (true) a else b 
//		}
//		'''.parseAndInfer.asserting [
//			assertTypeOf(classTypeFor(INTEGER), "a")
//			assertTypeOf(classTypeFor(INTEGER), "b")
//		]
//	}
//
//	@Test
//	def void testInferTHENFromELSE() {
//		''' 
//		program p {
//			const a
//			const number = if (true) a else 23
//		}
//		'''.parseAndInfer.asserting [
//			assertTypeOf(classTypeFor(INTEGER), "a")
//		]
//	}
//
//	@Test
//	def void testInferELSEFromTHEN() {
//		'''
//		program p {
//			const a
//			const number = if (true) 23 else a
//		}
//		'''.parseAndInfer.asserting [
//			assertTypeOf(classTypeFor(INTEGER), "a")
//		]
//	}

	@Test
	def void testCheckIfConditionMustBeBoolean() {
		'''
		program p {
			const n = 23
			const number = if (n) 2 else 6
		}
		'''.parseAndInfer.asserting [
			findByText("n", WVariableReference).assertIssuesInElement("expected <<Boolean>> but found <<Integer>>")
		]
	}

}
