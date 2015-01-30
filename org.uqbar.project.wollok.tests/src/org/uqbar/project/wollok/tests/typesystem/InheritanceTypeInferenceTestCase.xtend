package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test

import static org.uqbar.project.wollok.semantics.WollokType.*

/**
 * 
 * @author jfernandes
 */
class InheritanceTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {
	
	@Test
	def void testVariableInferredToSuperClassWhenAssignedTwoDifferentSubclasses() { #['''
			class Animal {}
			class Golondrina extends Animal {}
			class Perro extends Animal {}
		''', ''' program p {
			var animal
			animal = new Golondrina()
			animal = new Perro()
		}'''].parseAndInfer.asserting [
			noIssues
			assertTypeOf(classType('Animal'), 'var animal')
		]
	}
	
	// method inheritance
		
	@Test
	def void testMethodReturnTypeInferredFromSuperMethod() { '''
			class Animal {
				var energia = 100
				method getEnergia() { energia }
			}
			class Golondrina extends Animal {
				override method getEnergia() {
					null
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Int", 'Golondrina.getEnergia')
			assertTypeOf(WInt, "null")
		]
	}
	
	@Test
	def void testInstVarInferredTransitivelyFromInheritedReturnType() { '''
			class Animal {
				var energia = 100
				method getEnergia() { energia }
			}
			class Golondrina extends Animal {
				val energiaGolondrina
				override method getEnergia() {
					energiaGolondrina
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Int", 'Golondrina.getEnergia')
			assertInstanceVarType(WInt, 'Golondrina.energiaGolondrina')
		]
	}
	
	@Test
	def void testAbstractMethodReturnTypeInferredGeneralizingOverridingMethodsInSubclasses() { '''
			class AnimalFactory {
				method createAnimal()
			}
			class Animal {}
			class Perro extends Animal {}
			class Gato extends Animal {}
			
			class PerroFactory extends AnimalFactory {
				override method createAnimal() { new Perro() }
			}
			class GatoFactory extends AnimalFactory {
				override method createAnimal() { new Gato() }
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Animal", 'AnimalFactory.createAnimal')
		]
	}
	
	@Test
	def void testAbstractMethodParameterInferredFromOverridingMethodsInSubclassesWithBasicTypes() { '''
			class NumberOperation {
				def perform(aNumber)
			}
			class DoubleOperation extends NumberOperation {
				override method perform(aNumber) { aNumber + aNumber }
			}
			class TripleOperation extends NumberOperation {
				override method perform(aNumber) { aNumber * 3 }
			} 
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Int) => Int", 'NumberOperation.perform')
			assertMethodSignature("(Int) => Int", 'DoubleOperation.perform')
			assertMethodSignature("(Int) => Int", 'TripleOperation.perform')
		]
	}
	
	// ***********************************************
	// ** structural to nominal inference
	// ***********************************************
	
	/**
	 * <<<<< ESTE ES MAS HEAVY QUE EL DIABLO !!! >>>>>
	 */
	@Test
	def void testAbstractMethodParameterInferredFromOverridingMethodsInSubclassesThroughStructuralTypes() { '''
			class Animal {}
			class Perro extends Animal { def ladrar() { 'Guau!' } }
			class Gato extends Animal { def mauyar() { 'Miau!' } }
			
			class Entrenador {
				def entrenar(unAnimal)
			}
			class EntrenadorDePerros extends Entrenador {
				override method entrenar(unAnimal) { 
					unAnimal.ladrar()
				}
			}
			class EntrenadorDeGatos extends Entrenador {
				override method entrenar(unAnimal) {
					unaAnimal.mauyar()
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Animal) => String", 'Entrenador.entrenar')
			assertMethodSignature("(Animal) => String", 'EntrenadorDePerros.entrenar')
			assertMethodSignature("(Animal) => String", 'EntrenadorDePerros.entrenar')
		]
	}
	
}