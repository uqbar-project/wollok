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

	@Parameters(name="{index}: {0}")
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
	def void empty_method_not_produce_effect() {
		''' object o { method m() { } } '''.parseAndInfer.asserting [
			assertEffectOfMethod(Nothing, "o.m")
		]
	}

	@Test
	def void method_not_produce_effect() {
		''' object o { method m() { return 42 } } '''.parseAndInfer.asserting [
			assertEffectOfMethod(Nothing, "o.m")
		]
	}
	
	@Test
	def void local_change_not_produce_effect() {
		''' object o { method m() { var x = 1; x = 2 } } '''.parseAndInfer.asserting [
			assertEffectOfMethod(Nothing, "o.m")
		]
	}

	@Test
	def void method_produce_effect_on_named_object() {
		''' object o { 
			var x
			method m() {
				x = 1
			}
		} '''.parseAndInfer.asserting [
			assertEffectOfMethod(Change, "o.m")
		]
	}

	@Test
	def void method_produce_effect_transitive() {
		''' 
			object o { 
				var x = 1
				method m(ave) {
					ave.comer(x)
				}
			}
			
			object pepita {
				var energia = 0
				method comer(grms) {
					energia += grms
				} 
			}
		'''.parseAndInfer.asserting [
			assertEffectOfMethod(Change, "o.m")
		]
	}
	

	@Test
	def void method_not_produce_effect_transitive() {
		''' 
			object o {
				var x = 1
				method m(ave) {
					ave.comer(x)
					return 42
				}
			}
			
			object pepona{
				method comer(grms) { }
			}
		'''.parseAndInfer.asserting [
			assertEffectOfMethod(Nothing, "o.m")
		]
	}
	
	@Test
	def void method_produce_effect_on_class_instance() {
		''' 
		class C { 
			var x
			method m() {
				x = 1 
			}
		} 
		'''.parseAndInfer.asserting [
			assertEffectOfMethod(Change, "C.m")
		]
	}
	
	@Test
	def void method_produce_effect_locally_on_class_instance() {
		''' 
		class C { 
			var x
			method m() {
				x = 1 
			}
		}
		
		object o {
			method t() {
				new C().m()
			}
		} 
		'''.parseAndInfer.asserting [
			assertEffectOfMethod(Change, "C.m")
			assertEffectOfMethod(Nothing, "o.t")
		]
	}
	
	@Test
	def void method_produce_effect_non_locally_on_class_instance() {
		''' 
		class C { 
			var x
			method effect() {
				x = 1 
			}
		}
		
		object o {
			const c = new C()
			
			method t() {
				c.effect()
			}
		} 
		'''.parseAndInfer.asserting [
			assertEffectOfMethod(Change, "C.effect")
			assertEffectOfMethod(Change, "o.t")
		]
	}
}
