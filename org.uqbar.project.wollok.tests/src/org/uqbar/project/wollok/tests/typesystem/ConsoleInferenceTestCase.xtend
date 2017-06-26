package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * Test cases for type inference of closures.
 * 
 * @author npasserini
 */
class ConsoleInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Object[] typeSystems() {
		#[
//			SubstitutionBasedTypeSystem,
			ConstraintBasedTypeSystem
		]
	}

	@Test
	def void typeOfCoreWKO() {
		'''
			program p {
				console
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(objectType(CONSOLE), 'console')
		]
	}

	@Test
	def void coreWKOMethodSignature() {
		'''
			program p {
				console.println("hola")
			}
		'''.parseAndInfer.asserting [
			assertMethodSignature("(String) => Void", 'console.println')
		]
	}
}
