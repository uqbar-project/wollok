package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.semantics.XSemanticsTypeSystem
import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

import static org.uqbar.project.wollok.typesystem.WollokType.*

/**
 * The most basic inference tests
 * 
 * @author npasserini
 */
class LiteralsInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			new SubstitutionBasedTypeSystem,
			new XSemanticsTypeSystem,		 
			new ConstraintBasedTypeSystem,
			new BoundsBasedTypeSystem
		]
	}

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