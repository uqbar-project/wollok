package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Tests number literals cache.
 * The interpreter won't create new instances for the same number.
 * 
 * @author jfernandes
 */
class NumberIdentityTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testTwoLiterals() {
		'''
		program p {
			assert.that(33.identity() == 33.identity())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testTwoVariablesInSameProgram() {
		'''
		program p {
			var a = 33
			var b = 33
			
			assert.that(a.identity() == b.identity())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testVariablesInDifferentScopes() {
		'''
		program p {
			var a = 33
			
			var o = object {
				var b = 33
				method getB() { return b }
			}
			
			assert.that(a.identity() == o.getB().identity())
		}'''.interpretPropagatingErrors
	}
	
		@Test
	def void testTwoDoubleLiterals() {
		'''
		program p {
			assert.that((33.0).identity() == (33.0).identity())
		}'''.interpretPropagatingErrors
	}
	
}