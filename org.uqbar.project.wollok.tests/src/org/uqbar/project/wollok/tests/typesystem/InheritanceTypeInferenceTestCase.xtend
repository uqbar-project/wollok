package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import org.junit.Ignore

/**
 * 
 * @author jfernandes
 */
class InheritanceTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Object[] typeSystems() {
		#[
//			SubstitutionBasedTypeSystem,	//TO BE FIXED
			ConstraintBasedTypeSystem
		// ,XSemanticsTypeSystem			// TODO 
		// BoundsBasedTypeSystem,    TO BE FIXED
		]
	}

	@Test
	def void testVariableInferredToSuperClassWhenAssignedTwoDifferentSubclasses() {
		#['''
		class Animal {}
		class Golondrina inherits Animal {}
		class Perro inherits Animal {}
		
		 program p {
			var animal
			animal = new Golondrina()
			animal = new Perro()
		}'''].parseAndInfer.asserting [
//			noIssues
			assertTypeOf(classType('Animal'), 'animal')
		]
	}

	@Test
	def void testMethodReturnTypeInferredFromSuperMethod() {
		'''
			class Animal {
				method getEnergia() { return 100 }
			}
			class Golondrina inherits Animal {
				var energia
				override method getEnergia() {
					return energia
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Integer", 'Golondrina.getEnergia')
			assertInstanceVarType(classTypeFor(INTEGER), 'Golondrina.energia')
		// assertTypeOf(classTypeFor(INTEGER), "null")
		]
	}

	@Test
	def void testInstVarInferredTransitivelyFromInheritedReturnType() {
		'''
			class Animal {
				var energia = 100
				method getEnergia() { return energia }
			}
			class Golondrina inherits Animal {
				const energiaGolondrina
				override method getEnergia() {
					return energiaGolondrina
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Integer", 'Golondrina.getEnergia')
			assertInstanceVarType(classTypeFor(INTEGER), 'Golondrina.energiaGolondrina')
		]
	}

	@Test
	def void testAbstractMethodReturnTypeInferredGeneralizingOverridingMethodsInSubclasses() {
		'''
			class AnimalFactory {
				method createAnimal()
			}
			class Animal {}
			class Perro inherits Animal {}
			class Gato inherits Animal {}
			
			class PerroFactory inherits AnimalFactory {
				override method createAnimal() { return new Perro() }
			}
			class GatoFactory inherits AnimalFactory {
				override method createAnimal() { return new Gato() }
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("() => Animal", 'AnimalFactory.createAnimal')
			assertMethodSignature("() => Gato", 'GatoFactory.createAnimal')
			assertMethodSignature("() => Perro", 'PerroFactory.createAnimal')
		]
	}

	@Test
	@Ignore
	def void testAbstractMethodParameterInferredFromOverridingMethodsInSubclassesWithBasicTypes() {
		'''
			class NumberOperation {
				method perform(aNumber)
			}
			class DoubleOperation inherits NumberOperation {
				override method perform(aNumber) { return aNumber + aNumber }
			}
			class TripleOperation inherits NumberOperation {
				override method perform(aNumber) { return 3 * aNumber }
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
	@Ignore("Este test está mal")
	def void testAbstractMethodParameterInferredFromOverridingMethodsInSubclassesThroughStructuralTypes() {
		'''
			class Animal {}
			class Perro inherits Animal { method ladrar() { return 'Guau!' } }
			class Gato inherits Animal { method mauyar() { return 'Miau!' } }
			
			class Entrenador {
				method entrenar(unAnimal)
			}
			class EntrenadorDePerros inherits Entrenador {
				override method entrenar(unAnimal) { 
					return unAnimal.ladrar()
				}
			}
			class EntrenadorDeGatos inherits Entrenador {
				override method entrenar(unAnimal) {
					return unAnimal.mauyar()
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertMethodSignature("(Animal) => String", 'Entrenador.entrenar')
			assertMethodSignature("(Animal) => String", 'EntrenadorDePerros.entrenar')
			assertMethodSignature("(Animal) => String", 'EntrenadorDeGatos.entrenar')
		]
	}

}
