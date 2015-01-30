package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test

import static org.uqbar.project.wollok.semantics.WollokType.*

/**
 * The most basic inference tests
 * 
 * @author npasserini
 */
class LiteralsInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Test
	def void testNumberLiteral() { 	''' program {
		46
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "46")
		]
	}

	@Test
	def void testStringLiteral() { 	''' program {
		"Hello"
		}'''.parseAndInfer.asserting [
			assertTypeOf(WString, '''"Hello"''')
		]
	}

	@Test
	def void testBooleanLiteral() { 	''' program p {
		true
		}'''.parseAndInfer.asserting [
			assertTypeOf(WBoolean, "true")
		]
	}
}