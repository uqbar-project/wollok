package org.uqbar.project.wollok.tests.interpreter.namedobjects

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * @author jfernandes
 */
class UnnamedObjectTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testObjectScopingUsingVariableDefinedOutsideOfIt() {
		'''
		program p {
			var n = 33
			
			const o = object {
				method getN() {
					return n
				}
			} 
			
			assert.that(33 == o.getN())
			
			// change N
			n = 34
			
			assert.that(34 == o.getN())
		}'''.interpretPropagatingErrors
	}
	
}