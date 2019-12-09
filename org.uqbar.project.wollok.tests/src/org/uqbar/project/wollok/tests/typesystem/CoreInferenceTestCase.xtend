package org.uqbar.project.wollok.tests.typesystem

import org.junit.jupiter.api.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class CoreInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
		]
	}
	
	@Test
	def void allCoreMethodsTyped() {
		'''
			program p { }
		'''.parseAndInfer.asserting [
			(WNamedObject.findAll + WClass.findAll)
			.filter[fqn != CLOSURE]
			.forEach[methods.allTyped]
		]
	}
	
	// If type declaration doesn't exist for any method throws TypeSystemException
	def allTyped(Iterable<WMethodDeclaration> methods) {
		methods.forEach[
			(tsystem as ConstraintBasedTypeSystem)
			.registry
			.tvarOrParam(it) // TODO: Access restriction problem 
		]
	}
}
