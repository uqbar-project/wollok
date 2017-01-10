package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.semantics.XSemanticsTypeSystem
import org.uqbar.project.wollok.typesystem.bindings.BoundsBasedTypeSystem
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * The most basic inference tests
 * 
 * @author npasserini
 * @author jfernandes
 */
class LiteralsInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			SubstitutionBasedTypeSystem,
			XSemanticsTypeSystem,		 
			ConstraintBasedTypeSystem,
			BoundsBasedTypeSystem
		]
	}

	@Test
	def void testNumberLiteral() { 	
		''' program { 46 } '''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(INTEGER), "46")
		]
	}

	@Test
	def void testStringLiteral() {
		''' program { "Hello" } '''
		.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(STRING), '''"Hello"''')
		]
	}

	@Test
	def void testBooleanLiteral() {
		'''program p { true }'''
		.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(BOOLEAN), "true")
		]
	}
}