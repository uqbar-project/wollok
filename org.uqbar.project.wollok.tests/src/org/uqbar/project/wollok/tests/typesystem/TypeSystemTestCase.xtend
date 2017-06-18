package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

/**
 * Tests type system inference and checks
 * 
 * @author jfernandes
 */
class TypeSystemTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Class<? extends TypeSystem>[] typeSystems() {
		#[
			SubstitutionBasedTypeSystem
//			new XSemanticsTypeSystem,
			,
			ConstraintBasedTypeSystem // TODO: fix !
//			new BoundsBasedTypeSystem
		]
	}

	@Test
	def void testInferSimpleVariableAssignment() {
		''' program p {
			const number = 23
		}'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(INTEGER), 'number')
		]
	}

	@Test
	def void testInferIndirectVar() {
		'''
			program p {
				const number
				number = 23
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(INTEGER), 'number')
		]
	}

	@Test
	def void testInferIndirectAssignedToBinaryExpression() {
		'''
			program p {
				const number
				const a = 2
				const b = 3
				number = a + b
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(INTEGER), 'number')
		]
	}

	@Test
	def void testIncompatibleTypesInAssignment() {
		''' 
			program p {
				var a = 2
				const b = "aString"
				a = b
			}
		'''.parseAndInfer.asserting [
			assertIssues("a = b", "Expecting super type of <<Integer>> but found <<String>> which is not")
		]
	}

	@Test
	def void testClassType() {
		'''
			class Pato {
				method cuack() { 'cuack!' }
			}
			
			program p {
				const pato = new Pato()
				pato.cuack()
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertTypeOf(classType("Pato"), 'pato')
		]
	}

	@Test
	def void testInferRightOperandFromBinaryExpression() {
		'''
			class Golondrina {
				var energia
				method come(grms) {
					energia = 10 + grms
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Integer) => Void", "Golondrina.come")
		]
	}

	@Test
	def void testInferLeftOperandFromBinaryExpression() {
		'''
			class Golondrina {
				var energia
				method come(grms) {
					energia = grms + 10
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Integer) => Void", "Golondrina.come")
		]
	}
}
