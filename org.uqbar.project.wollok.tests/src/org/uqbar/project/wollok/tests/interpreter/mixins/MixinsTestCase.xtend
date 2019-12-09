package org.uqbar.project.wollok.tests.interpreter.mixins

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.api.Test

/**
 * 
 * @author jfernandes
 */
class MixinsTestCase extends AbstractWollokInterpreterTestCase {
	

	def String toStringFixture() {
		'''
		class Persona {
			var edad = 10
			
			method envejecer(cuanto) {
				edad += cuanto
			}
		}
		
		mixin EnvejeceDoble {
			method envejecer(cuanto) {
				super(cuanto * 2)
			}
		}
		
		mixin EnvejeceTriple {
			method envejecer(cuanto) {
				super(cuanto * 3)
			}
		}
		'''	
	}
	
	@Test
	def void toString1() {
		'''
		«toStringFixture»
		test "toString de un mixed method container con 1 mixin" {
			const pm = new Persona() with EnvejeceDoble
			assert.equals(pm.toString(), "Persona with EnvejeceDoble[edad=10]")
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void toString2() {
		'''
		«toStringFixture»
		test "toString de un mixed method container con 2 mixins" {
			const pm = new Persona() with EnvejeceDoble with EnvejeceTriple
			assert.equals(pm.toString(), "Persona with EnvejeceDoble with EnvejeceTriple[edad=10]")
		}
		'''.interpretPropagatingErrors
	}
}