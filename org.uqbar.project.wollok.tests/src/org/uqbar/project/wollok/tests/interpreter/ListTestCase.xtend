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
			this.assert(3 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testContains() {
		'''
		program p {
			val numbers = #[23, 2, 1]		
			this.assert(numbers.contains(23))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testRemove() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			numbers.remove(23)		
			this.assert(2 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testClear() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			numbers.clear()		
			this.assert(0 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testIsEmpty() {
		'''
		program p {
			val numbers = #[23, 2, 1]
			this.assertFalse(numbers.isEmpty())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testForEach() {
		'''
		program p {
			
			val numbers = #[23, 2, 1]
			
			var sum = 0
			numbers.forEach([n | sum += n])
			
			this.assertEquals(26, sum)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testForAll() {
		'''
		program p {
			
			val numbers = #[23, 2, 1]
			
			var allPositives = numbers.forAll([n | n > 0])
			
			this.assert(allPositives)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testFilter() {
		'''
		program p {
				val numbers = #[23, 2, 1]
				var greaterThanOneElements = numbers.filter([n | n > 1])
				this.assert(greaterThanOneElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMap() {
		'''
		program p {
			val numbers = #[10, 20, 30]
			var halfs = numbers.map([n | n / 2])

			this.assert(halfs.contains(5))
			this.assert(halfs.contains(10))
			this.assert(halfs.contains(15))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testShortCutAvoidingParenthesis() {
		'''
		program p {
				val numbers = #[23, 2, 1]
				var greaterThanOneElements = numbers.filter[n | n > 1]
				this.assert(greaterThanOneElements.size() == 2)
		}'''.interpretPropagatingErrors
	}

}