package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author jfernandes
 */
class PostFixOperationTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testPlusPlus() {''' 
		program p {
			var n = 1
			n++
			
			this.assert(n == 2) 
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMinusMinus() {'''
		program p {
			var n = 2
			n--
			
			this.assert(n == 1)
		}'''.interpretPropagatingErrors
	}
}