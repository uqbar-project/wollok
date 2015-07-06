package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author tesonep
 */
class SubstringTestTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testWithAssertsOk() {
		'''
			test pepita {
				val x = "Hola, wollok!".substring(0,3)
				this.assertEquals("Hol", x)			
			}
		'''.interpretPropagatingErrors
	}
	
}