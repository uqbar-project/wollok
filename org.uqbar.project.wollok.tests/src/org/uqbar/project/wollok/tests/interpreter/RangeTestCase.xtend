package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Tests wollok ranges
 * 
 * @author jfernandes
 */
class RangeTestCase extends AbstractWollokInterpreterTestCase {

	@Test
	def void testForEach() {
		'''
		program a {
			const range = 0 .. 10
			
			var sum = 0
			
			assert.that(range != null)
			
			range.forEach { i => sum += i }
			
			assert.equals(55, sum)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testRangeForDecimalsNotAllowed() {
		'''
		program a {
			assert.throwsException({ => new Range(2.0, 5.0)})
		}
		'''.interpretPropagatingErrors
	}	

	@Test
	def void testRangeForStringsNotAllowed() {
		'''
		program a {
			assert.throwsException({ => new Range("ABRACADBRA", "PATA")})
		}
		'''.interpretPropagatingErrors
	}	
	
}