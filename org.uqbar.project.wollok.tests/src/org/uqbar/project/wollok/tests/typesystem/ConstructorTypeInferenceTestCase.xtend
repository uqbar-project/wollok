package org.uqbar.project.wollok.tests.typesystem

import org.junit.jupiter.api.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

/**
 * 
 * @author jfernandes
 */
class ConstructorTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {
	
	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
		]
	}
	
	@Test
	def void testConstructorParameterTypeInferredFromInstVarAssignment() {	 '''
			class Direccion {
				var calle = ""
				var numero = 0
				
				constructor(c, n) {
					calle = c
					numero = n
				}
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertConstructorType("Direccion", "(String, Number)")
		]
	}
	
}