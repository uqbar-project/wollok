package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test
import org.uqbar.project.wollok.WollokDSLKeywords

/**
 * Test cases for operators such as: +=, -=, etc.
 * 
 * @author jfernandes
 */
class MultiOpAssignTestCase extends AbstractWollokInterpreterTestCase {
	@Test
	def void testPlusEquals() {'''
		program p {
			var n = 1
			n += 1
			
			assert.that(n == 2) 
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMultiplyEquals() {'''
		program p {
			var n = 2
			n *= 3
			
			assert.that(n == 6)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testSubstractEquals() {'''
		program p {
			var n = 2
			n -= 1
			
			assert.that(n == 1)
		}'''.interpretPropagatingErrors
	}
	
	// helper for impl
	
	@Test
	def void testMatches() {
		// valid
		#["+=", "-=", "*=", "/=", "%="].forEach[s|
			assertTrue(s.matches(WollokDSLKeywords.MULTIOPS_REGEXP))
		]
		// not valid
		#["++=", "+_", "a="].forEach[s|
			assertFalse(s.matches(WollokDSLKeywords.MULTIOPS_REGEXP))
		]
	}
}