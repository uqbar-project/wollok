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
	def void fold() {
		'''
		program a {
			var range = 0 .. 10 
			var sum = range.fold(0, { acum, each => acum + each })
			assert.equals(55, sum)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void size() {
		'''
		program a {
			var range = 0 .. 10 
			assert.equals(11, range.size())
			assert.equals(10, (12..21).size())
			assert.equals(7, (-3..3).size())
		}
		'''.interpretPropagatingErrors
	
	}
	
	@Test
	def void any() {
		'''
		program a {
			var range = 0 .. 10 
			assert.that(range.any({ elem => elem == 5}))
			assert.notThat(range.any({ elem => elem == 15}))
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