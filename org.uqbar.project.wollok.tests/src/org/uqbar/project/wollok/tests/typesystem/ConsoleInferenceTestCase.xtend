package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

import org.junit.Ignore
import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * Test cases for type inference related to the console object.
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
			assertTypeOf(objectTypeFor(CONSOLE), 'console')
		]
	}

	@Test
	@Ignore
	def void coreWKOMethodSignature() {
		'''
			program p {
				console.println("hola")
			}
		'''.parseAndInfer.asserting [
			assertMethodSignature("(Any) => Void", 'console.println')
		]
	}
}
