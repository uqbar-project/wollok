package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.semantics.XSemanticsTypeSystem
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

/**
 * The most basic inference tests
 * 
 * @author npasserini
 */
class ConstantInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			SubstitutionBasedTypeSystem,
			XSemanticsTypeSystem,
			ConstraintBasedTypeSystem
//			BoundsBasedTypeSystem,    TO BE FIXED
		]
	}

	@Test
	def void numberLiteral() { 	'''program p {
			const a = 46
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(INTEGER), "a")
		]
	}
	
	@Test
	def void stringLiteral() { 	'''program p {
			const b = "Hello"
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(STRING), "b")
		]
	}
	
	@Test
	def void booleanLiteral() { 	'''program p {
			const c = true
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(BOOLEAN), "c")
		]
	}
	
	@Test
	def void listLiteral() { 	'''program p {
			const c = [1,2,3]
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(LIST), "c")
		]
	}
	
	@Test
	def void setLiteral() { 	'''program p {
			const c = #{1,2,3}
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(SET), "c")
		]
	}

	def void setConstant() {
		'''
			program p {
				const a = 46
				const b = a
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(INTEGER), "b")
		]
	}			
}