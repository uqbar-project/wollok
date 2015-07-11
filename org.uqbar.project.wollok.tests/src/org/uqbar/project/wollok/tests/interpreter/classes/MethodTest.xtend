package org.uqbar.project.wollok.tests.interpreter.classes

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * @author jfernandes
 */
class MethodTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void shortSyntaxForMethodsReturningAValue() { '''
		class Golondrina {
			var energia = 100
		
			method energia() = energia
			method capacidadDeVuelo() = 10
		}
		program p {
			val pepona = new Golondrina()
			assert.equals(pepona.energia(), 100)
			assert.equals(pepona.capacidadDeVuelo(), 10)
		}'''.interpretPropagatingErrors
	}
	
}