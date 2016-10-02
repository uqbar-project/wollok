package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import wollok.lang.WBoolean
import wollok.lang.WString

import static org.uqbar.project.wollok.typesystem.WollokType.*

/**
 * The most basic inference tests
 * 
 * @author npasserini
 */
class ConstantInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Test
	def void testNumberLiteral() { 	'''program p {
			const a = 46
			const b = "Hello"
			const c = true
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "const a = 46")
			assertTypeOf(WString, 'const b = "Hello"')
			assertTypeOf(WBoolean, "const c = true")
		]
	}
}