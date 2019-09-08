package org.uqbar.project.wollok.tests.typesystem

import org.junit.Ignore
import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.wollokDsl.WClass

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
	
	@Test
	def void allLangMethodsHaveTypes() {
		'''
			program p { }
		'''.parseAndInfer.asserting [
			val allTypes = WNamedObject.findAll + WClass.findAll
			allTypes.forEach[methods.allTyped]
		]
	}
	
	def allTyped(Iterable<WMethodDeclaration> methods) {
		// TODO: Access restriction problem 
		methods.forEach[
			(tsystem as ConstraintBasedTypeSystem)
			.registry
			.tvarOrParam(it) // If type declaration doesn't exist throws TypeSystemException
		]
	}
}
