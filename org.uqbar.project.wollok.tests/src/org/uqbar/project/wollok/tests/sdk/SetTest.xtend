package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.CollectionTestCase

/**
 * @author jfernandes
 */
// the inheritance needs to be reviewed if we add list specific tests it won't work here
class SetTest extends CollectionTestCase {
	
	override instantiateCollectionAsNumbersVariable() {
		"const numbers = #{22, 2, 10}"
	}

	override instantiateCollectionWithA2() {
		"const collectionWithA2 = #{2}"
	}
	
	override instantiateEmptyCollection() {
		"const emptyCollection = #{}"
	}
	
	@Test
	def void testSizeWithDuplicates() {
		'''
		program p {
			const numbers = #{ 23, 2, 1, 1, 1 }		
			assert.equals(3, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testSizeAddingDuplicates() {
		'''
		program p {
			const numbers = #{ 23, 2, 1, 1, 1 }
			numbers.add(1)
			numbers.add(1)		
			assert.equals(3, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testSizeAddingDuplicatesWithAddAll() {
		'''
		program p {
			const numbers = #{ 23, 2, 1, 1, 1 }
			numbers.add(#{1, 1, 1, 1, 4})
			assert.equals(4, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	override def void testToString() {
		'''
		program p {
			const a = #{23, 2, 2}
			const s = a.toString()
			assert.that("#{2, 23}" == s or "#{23, 2}" == s)
		}'''.interpretPropagatingErrors
	}
	
	override testToStringWithObjectRedefiningToStringInWollok() {
	}

	@Test
	def void testFlatMap() {
		'''
		program p {
			assert.equals(#{1,2,3,4}, #{#{1,2}, #{1,3,4}}.flatten())
			assert.equals(#{1,2, 3}, #{#{1,2}, #{}, #{1,2, 3}}.flatten())
			assert.equals(#{}, #{}.flatten())
			assert.equals(#{}, #{#{}}.flatten())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testConversions() {
		'''
		program p {
			const set= #{1,2,3}
			assert.equals(#{1,2,3}, set.asSet())
			
			const list = set.asList()
			assert.equals(3, list.size())
			[1,2,3].forEach{i=>assert.equals(list.contains(i))}
		}'''.interpretPropagatingErrors
	}
	
	override removeAll() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			numbers.removeAll(#{2, 10})
			assert.equals(#{22}, numbers)
		}'''.interpretPropagatingErrors
	}	
}
