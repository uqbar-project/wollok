package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.semantics.XSemanticsTypeSystem
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

import static org.uqbar.project.wollok.typesystem.WollokType.*

/**
 * The most basic inference tests
 * 
 * @author npasserini
 */
class ConstantInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			new SubstitutionBasedTypeSystem,
			new XSemanticsTypeSystem
//			new ConstraintBasedTypeSystem			TO BE FIXED
//			new BoundsBasedTypeSystem,    TO BE FIXED
		]
	}

	@Test
	def void testNumberLiteral() { 	'''program p {
			const a = 46
			const b = "Hello"
			const c = true
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "a")
			assertTypeOf(WString, 'b')
			assertTypeOf(WBoolean, "c")
		]
	}
}