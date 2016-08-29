package org.uqbar.project.wollok.tests.typesystem

import org.junit.Ignore
import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

import static org.uqbar.project.wollok.typesystem.WollokType.*

/**
 * Test type inference in if expressions
 * 
 * @author jfernandes
 */
class IfTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			new SubstitutionBasedTypeSystem
//			new XSemanticsTypeSystem			// TODO 
//			new ConstraintBasedTypeSystem			TO BE FIXED
//			new BoundsBasedTypeSystem,    TO BE FIXED
		]
	}

	@Test
	def void testIfBranchesInferredFromOutside() { 	''' program p {
			const a
			const b
			const number = 23
			number = if (true) a else b 
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "a")
			assertTypeOf(WInt, "b")
		]
	}

	@Test
	def void testInferTHENFromELSE() {	''' program p {
			const a
			const number = if (true) a else 23
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "a")
		]
	}

	@Test
	def void testInferELSEFromTHEN() { ''' program p {
			const a
			const number = if (true) 23 else a
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "a")
		]
	}

	@Test
	@Ignore
	def void testCheckIfConditionMustBeBoolean() { ''' program p {
			const n = 23
			const number = if (n) 2 else 6
		}'''.parseAndInfer.asserting [
			assertIssues("n", "ERROR: expected <<boolean>> but found <<Int>>")
		]
	}

}
