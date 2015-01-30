package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Tests polymorphism in different cases: object literals,
 * classes, etc.
 * 
 * 
 * @author jfernandes
 */
class PolymorphismTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testPolymorphicParameterWithObjectLiterals() {
		'''
		program p {
		val pepona = object {
			var energia = 100
			method comer(comida) {
				energia = energia + comida.energia()
			}
			method energia() { energia }
		}

		val alpiste = object {
			method energia() { 5 }
		}

		pepona.comer(alpiste)
		
		this.assert(105 == pepona.energia())
		}'''.interpretPropagatingErrors
	}
	
}