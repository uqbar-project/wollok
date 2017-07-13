package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * Groups together all test cases for method type inference.
 * Just a way to start splitting tests into several classes
 * 
 * @author jfernandes
 */
class MethodTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
//			SubstitutionBasedTypeSystem
		// TODO: fix !
//			XSemanticsTypeSystem,		 
//			BoundsBasedTypeSystem
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
			assertMethodSignature("(Number) => Void", "Golondrina.come")
		]
	}

	@Test
	def void testMethodReturnTypeInferredFromInstVarRef() {
		'''
			class Golondrina {
				var energia = 100
				method getEnergia() = energia
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Integer", "Golondrina.getEnergia")
		]
	}

	@Test
	def void testMethodReturnTypeInferredFromInstVarRefWithReturn() {
		'''
			class Golondrina {
				var energia = 100
				method getEnergia() { return energia }
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Integer", "Golondrina.getEnergia")
		]
	}

	@Test
	def void testMethodParamTypeInferredFromInstVarRef() {
		'''
			class Golondrina {
				var energia = 100
				method setEnergia(e) { energia = e }
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Integer) => Void", "Golondrina.setEnergia")
		]
	}

	@Test
	def void testMethodParamInferredFromInstVarRef() {
		'''
			class Golondrina {
				var energia = 100
				method multiplicarEnergia(factor) { 
					energia = energia * factor
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Integer) => Void", "Golondrina.multiplicarEnergia")
		]
	}

	@Test
	def void testMethodReturnTypeInferredFromInnerCallToOtherMethod() {
		'''
			class Golondrina {
				var energia = 100
				method getEnergia() { return energia }
				method getEnergiaDelegando() {
					return self.getEnergia()
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Integer", 'Golondrina.getEnergia')
			assertMethodSignature("() => Integer", 'Golondrina.getEnergiaDelegando')
		]
	}

	@Test
	def void testMethodReturnTypeInferredBecauseItIsUsedInOtherMethod() {
		'''
			class Golondrina {
				var energia = 100
				var gasto
				method volar() {
					energia = energia - self.gastoPorVolar() 
				}
				method gastoPorVolar() {
					return gasto
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Void", 'Golondrina.volar')
			assertMethodSignature("() => Integer", 'Golondrina.gastoPorVolar')
		]
	}

	@Test
	def void testMethodParameterInferredFromSuperMethod() {
		'''
			class Golondrina {
				var energia = 100
				method comer(gramos) {
					energia = energia + gramos 
				}
			}
			class GolondrinaIneficiente inherits Golondrina {
				override method comer(gramos) { }
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Integer) => Void", 'Golondrina.comer')
			assertMethodSignature("(Integer) => Void", 'GolondrinaIneficiente.comer')
		]
	}

	// Method Calls
	@Test
	def void variableAssignedToReturnValueOfSelfMethod() {
		'''
		object example {
			method aList() = [1,2,3]
			method useTheList() {
				const pepe = self.aList()
			}
		}'''.parseAndInfer.asserting [
			assertTypeOfAsString("List", "pepe")
		]
	}

	@Test
	def void messageTo() {
		'''
			object example {
				method number() = 10
			}
			
			program {
				var x = example.number()
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(INTEGER), "x")
		]
	}

//	@Test
//	def void variableAssignedToReturnValueOfAnotherObjectsMethod() { 	'''
//		object stringGenerator {
//			method generateString() = "ABC"
//		}
//		object stringConsumer {
//			method consume() {
//				const pepe = stringGenerator.generateString()
//			}
//		}
//		
//		'''.parseAndInfer.asserting [
//			assertTypeOfAsString("List", "pepe")
//		]
//	}
}
