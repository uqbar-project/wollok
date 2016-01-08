package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import static org.uqbar.project.wollok.typesystem.WollokType.*
import org.junit.Ignore

/**
 * Test type inference in if expressions
 * 
 * @author jfernandes
 */
class IfTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Test
	def void testIfBranchesInferredFromOutside() { 	''' program p {
			val a
			val b
			val number = 23
			number = if (true) a else b 
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "val a")
			assertTypeOf(WInt, "val b")
		]
	}

	@Test
	def void testInferTHENFromELSE() {	''' program p {
			val a
			val number = if (true) a else 23
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "val a")
		]
	}

	@Test
	def void testInferELSEFromTHEN() { ''' program p {
			val a
			val number = if (true) 23 else a
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "val a")
		]
	}

	@Test
	@Ignore
	def void testCheckIfConditionMustBeBoolean() { ''' program p {
			val n = 23
			val number = if (n) 2 else 6
		}'''.parseAndInfer.asserting [
			assertIssues("n", "ERROR: expected <<boolean>> but found <<Int>>")
		]
	}

}
