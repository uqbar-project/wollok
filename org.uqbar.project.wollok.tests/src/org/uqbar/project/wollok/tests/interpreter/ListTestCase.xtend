package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author jfernandes
 */
class ListTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testSize() {
		'''
		program p {
			val numbers = #[23, 2, 1]		
			assert.equals(3, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testContains() {
		'''
		program p {
			val numbers = #[23, 2, 1]		
			assert.that(numbers.contains(23))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testRemove() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			numbers.remove(23)		
			assert.that(2 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testClear() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			numbers.clear()		
			assert.that(0 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testIsEmpty() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			assert.notThat(numbers.isEmpty())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testForEach() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			
			var sum = 0
			numbers.forEach([n | sum += n])
			
			assert.equals(26, sum)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testForAll() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			var allPositives = numbers.forAll([n | n > 0])
			assert.that(allPositives)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testFilter() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			var greaterThanOneElements = numbers.filter([n | n > 1])
			assert.that(greaterThanOneElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMap() {
		'''
		program p {
			val numbers = #[10, 20, 30]
			var halfs = numbers.map([n | n / 2])

			assert.that(halfs.contains(5))
			assert.that(halfs.contains(10))
			assert.that(halfs.contains(15))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testShortCutAvoidingParenthesis() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			var greaterThanOneElements = numbers.filter[n | n > 1]
			assert.that(greaterThanOneElements.size() == 2)
		}'''.interpretPropagatingErrors
	}

}