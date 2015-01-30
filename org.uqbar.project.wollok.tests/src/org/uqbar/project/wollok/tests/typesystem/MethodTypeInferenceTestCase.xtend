package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test

/**
 * Groups together all test cases for method type inference.
 * Just a way to start splitting tests into several classes
 * 
 * @author jfernandes
 */
class MethodTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {
	
	@Test
	def void testMethodReturnTypeInferredFromInstVarRef() {	 '''
			class Golondrina {
				var energia = 100
				method getEnergia() { energia }
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Int", "Golondrina.getEnergia")
		]
	}
	
	@Test
	def void testMethodParamTypeInferredFromInstVarRef() {	'''
			class Golondrina {
				var energia = 100
				method setEnergia(e) { energia = e }
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Int) => Void", "Golondrina.setEnergia")			
		]
	}
	
	@Test
	def void testMethodParamInferredFromInstVarRef() { 	'''
			class Golondrina {
				var energia = 100
				method multiplicarEnergia(factor) { 
					energia = energia * factor
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Int) => Void", "Golondrina.multiplicarEnergia")			
		]
	}
	
	@Test
	def void testMethodReturnTypeInferredFromInnerCallToOtherMethod() { 	'''
			class Golondrina {
				var energia = 100
				method getEnergia() { energia }
				method getEnergiaDelegando() {
					this.getEnergia()
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Int", 'Golondrina.getEnergia')
			assertMethodSignature("() => Int", 'Golondrina.getEnergiaDelegando')
		]
	}	
	
	@Test
	def void testMethodReturnTypeInferredBecauseItIsUsedInOtherMethod() { '''
			class Golondrina {
				var energia = 100
				var gasto
				method volar() {
					energia = energia - this.gastoPorVolar() 
				}
				method gastoPorVolar() {
					gasto
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Void", 'Golondrina.volar')
			assertMethodSignature("() => Int", 'Golondrina.gastoPorVolar')
		]
	}
	
	@Test
	def void testMethodParameterInferredFromSuperMethod() { '''
			class Golondrina {
				var energia = 100
				method comer(gramos) {
					energia = energia + gramos 
				}
			}
			class GolondrinaIneficiente extends Golondrina {
				override method comer(gramos) { }
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Int) => Void", 'Golondrina.comer')
			assertMethodSignature("(Int) => Void", 'GolondrinaIneficiente.comer')
		]
	}
	
}