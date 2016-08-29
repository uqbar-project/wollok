package org.uqbar.project.wollok.tests.typesystem

import org.junit.Ignore
import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.substitutions.SubstitutionBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * 
 * @author jfernandes
 */
class InheritanceTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {
	
	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			new SubstitutionBasedTypeSystem
//			new XSemanticsTypeSystem			// TODO 
//			new ConstraintBasedTypeSystem			TO BE FIXED
//			new BoundsBasedTypeSystem,    TO BE FIXED
		]
	}
	
	@Test
		@Ignore // FIX IT!
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
			class Golondrina inherits Animal {
				override method getEnergia() {
					null
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Integer", 'Golondrina.getEnergia')
			assertTypeOf(classTypeFor(INTEGER), "null")
		]
	}
	
	@Test
	def void testInstVarInferredTransitivelyFromInheritedReturnType() { '''
			class Animal {
				var energia = 100
				method getEnergia() { energia }
			}
			class Golondrina inherits Animal {
				const energiaGolondrina
				override method getEnergia() {
					energiaGolondrina
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Integer", 'Golondrina.getEnergia')
			assertInstanceVarType(classTypeFor(INTEGER), 'Golondrina.energiaGolondrina')
		]
	}
	
	@Test
	@Ignore // FIX IT!
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
	@Ignore // FIX IT!
	def void testAbstractMethodParameterInferredFromOverridingMethodsInSubclassesWithBasicTypes() { '''
			class NumberOperation {
				method perform(aNumber)
			}
			class DoubleOperation extends NumberOperation {
				override method perform(aNumber) { aNumber + aNumber }
			}
			class TripleOperation extends NumberOperation {
				override method perform(aNumber) { aNumber * 3 }
			} 
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Integer) => Integer", 'NumberOperation.perform')
			assertMethodSignature("(Integer) => Integer", 'DoubleOperation.perform')
			assertMethodSignature("(Integer) => Integer", 'TripleOperation.perform')
		]
	}
	
	// ***********************************************
	// ** structural to nominal inference
	// ***********************************************
	
	/**
	 * <<<<< ESTE ES MAS HEAVY QUE EL DIABLO !!! >>>>>
	 */
	@Test
	@Ignore // FIX IT!
	def void testAbstractMethodParameterInferredFromOverridingMethodsInSubclassesThroughStructuralTypes() { '''
			class Animal {}
			class Perro extends Animal { method ladrar() { 'Guau!' } }
			class Gato extends Animal { method mauyar() { 'Miau!' } }
			
			class Entrenador {
				method entrenar(unAnimal)
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