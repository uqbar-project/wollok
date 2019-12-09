package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.api.Test

/**
 * @author jfernandes
 */
class PostFixOperationTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testPlusPlus() {''' 
		program p {
			var n = 1
			n++
			
			assert.that(n == 2) 
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testPlusPlusWithDoubles() {'''
		program p {
			var n = 2.1
			n++
			
			assert.that(n == 3.1)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMinusMinus() {'''
		program p {
			var n = 2
			n--
			
			assert.that(n == 1)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMinusMinusWithDoubles() {'''
		program p {
			var n = 2.0
			n--
			
			assert.that(n == 1.0)
		}'''.interpretPropagatingErrors
	}
}