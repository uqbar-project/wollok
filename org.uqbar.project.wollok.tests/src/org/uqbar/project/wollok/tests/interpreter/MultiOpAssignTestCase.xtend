package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import static org.uqbar.project.wollok.WollokConstants.*
import org.junit.jupiter.api.Test

/**
 * Test cases for operators such as: +=, -=, etc.
 *
 * This tests should remain as part of Wollok-Xtext implementation
 *  
 * @author jfernandes
 */
class MultiOpAssignTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testMatches() {
		// valid
		#["+=", "-=", "*=", "/=", "%="].forEach[s|
			assertTrue(s.matches(MULTIOPS_REGEXP))
		]
		// not valid
		#["++=", "+_", "a="].forEach[s|
			assertFalse(s.matches(MULTIOPS_REGEXP))
		]
	}

}