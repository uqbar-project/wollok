package org.uqbar.project.wollok.tests.typesystem

import org.junit.Ignore
import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * The most basic inference tests
 * 
 * @author npasserini
 */
class ConstantInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
		]
	}

	@Test
	def void numberLiteral() { 	'''program p {
			const a = 46
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "a")
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
			assertTypeOfAsString("List", "c")
		]
	}
	
	@Test
	def void setLiteral() { 	'''program p {
			const c = #{1,2,3}
		}'''.parseAndInfer.asserting [
			assertTypeOfAsString("Set", "c")
		]
	}

	@Test
	def void setIndirectVar() {
		'''
			program p {
				var number
				number = 23
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "number")
		]
	}

	@Test
	def void setConstant() {
		'''
			program p {
				const a = 46
				const b = a
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "b")
		]
	}
	
	@Test
	def void classInstance() { 	'''
		class Golondrina { }
		
		program p {
			const c = new Golondrina()
		}'''.parseAndInfer.asserting [
			assertTypeOf(classType("Golondrina"), "c")
		]
	}
	

	@Ignore("As of 29/6/17 type system rules allow this assignment.")
	@Test
	def void incompatibleTypesAssignment() {
		''' 
			program p {
				var a = 2
				const b = "aString"
				a = b
			}
		'''.parseAndInfer.asserting [
			assertIssues("a = b", "Expecting super type of <<Number>> but found <<String>> which is not")
		]
	}		
}