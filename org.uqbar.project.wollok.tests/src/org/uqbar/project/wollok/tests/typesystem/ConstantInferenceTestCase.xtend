package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.semantics.XSemanticsTypeSystem
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

import static org.uqbar.project.wollok.typesystem.WollokType.*
import org.uqbar.project.wollok.sdk.WollokDSK

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
	def void numberLiteral() { 	'''program p {
			const a = 46
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, "a")
		]
	}
	
	@Test
	def void stringLiteral() { 	'''program p {
			const b = "Hello"
		}'''.parseAndInfer.asserting [
			assertTypeOf(WString, 'b')
		]
	}
	
	@Test
	def void booleanLiteral() { 	'''program p {
			const c = true
		}'''.parseAndInfer.asserting [
			assertTypeOf(WBoolean, "c")
		]
	}
	
	@Test
	def void listLiteral() { 	'''program p {
			const c = [1,2,3]
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(WollokDSK.LIST), "c")
		]
	}
	
	@Test
	def void setLiteral() { 	'''program p {
			const c = #{1,2,3}
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(WollokDSK.SET), "c")
		]
	}
			
}