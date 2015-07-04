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
			val range = 0 .. 10
			
			var sum = 0
			
			this.assert(range != null)
			
			range.forEach [ i | sum += i ]
			
			this.assertEquals(55, sum)
		}
		'''.interpretPropagatingErrors
	}
	
}