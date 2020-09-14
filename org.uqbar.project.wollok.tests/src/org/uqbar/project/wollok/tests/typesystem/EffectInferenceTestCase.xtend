package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*

/**
 * The most basic inference tests
 * 
 * @author npasserini
 * @author jfernandes
 */
class EffectInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name = "{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
		]
	}

	@Test
	def void literals_not_produce_effect() { 	
		''' program { 46 } '''.parseAndInfer.asserting [
			assertEffectOf(Nothing, "46")
		]
	}
	
	@Test
	def void assignation_produce_effect() { 	
		''' program { var x; x = 1 } '''.parseAndInfer.asserting [
			assertEffectOf(Change, "x = 1")
		]
	}
	
	@Test
	def void method_not_produce_effect() { 	
		''' object o { method m() { return 42 } } '''.parseAndInfer.asserting [
			assertEffectOfMethod(Nothing, "o.m")
		]
	}
	
	
	@Test
	def void method_produce_effect() { 	
		''' object o { 
			var x
			method m() {
				x = 1 
				return 42
			}
		} '''.parseAndInfer.asserting [
			assertEffectOfMethod(Change, "o.m")
		]
	}

}