package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

/**
 * Test cases for type inference of closures.
 * 
 * @author jfernandes
 */
class ClosureInferenceTestCase extends AbstractWollokTypeSystemTestCase {
	
	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			new SubstitutionBasedTypeSystem
//			,new XSemanticsTypeSystem
//			,new ConstraintBasedTypeSystem
//			,new BoundsBasedTypeSystem    
		]
	}
	
	@Test
	def void closureNoArgsReturnsStringLiteral() { 	'''program p {
			const c = { "Hello" }
		}'''.parseAndInfer.asserting [
			assertTypeOfAsString("() => String", "c")
		]
	}
	
	@Test
	def void closureWithMathOperation() { 	'''program p {
			const c = { a => 2 + a }
		}'''.parseAndInfer.asserting [
			assertTypeOfAsString("(Integer) => Integer", "c")
		]
	}
	
	@Test
	def void emptyClosure() { 	'''program p {
			const c = { }
		}'''.parseAndInfer.asserting [
			assertTypeOfAsString("() => Void", "c")
		]
	}
	
}