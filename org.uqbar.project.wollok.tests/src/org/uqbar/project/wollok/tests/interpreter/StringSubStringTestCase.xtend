package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author tesonep
 */
class TestTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testWithAssertsOk() {
		#[
		'''
			test pepita {
				val x = "Hola, wollok!".substring(0,3)
				tester.assertEquals("Hol", x)			
			}
		'''].interpretPropagatingErrors
	}
	
}