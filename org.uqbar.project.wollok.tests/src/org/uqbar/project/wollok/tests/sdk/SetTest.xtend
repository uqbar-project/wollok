package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.CollectionTestCase

/**
 * @author jfernandes
 * @author palumboN
 * @author tesonep
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
		const numbers = #{ 23, 2, 1, 1, 1 }		
		assert.equals(3, numbers.size())
		'''.test
	}
	
	@Test
	def void testSizeAddingDuplicates() {
		'''
		const numbers = #{ 23, 2, 1, 1, 1 }
		numbers.add(1)
		numbers.add(1)		
		assert.equals(3, numbers.size())
		'''.test
	}
	
	@Test
	def void testSizeAddingDuplicatesWithAddAll() {
		'''
		const numbers = #{ 23, 2, 1, 1, 1 }
		numbers.add(#{1, 1, 1, 1, 4})
		assert.equals(4, numbers.size())
		'''.test
	}
	
	@Test
	override def void testToString() {
		'''
		const a = #{23, 2, 2}
		const s = a.toString()
		assert.that("#{2, 23}" == s or "#{23, 2}" == s)
		'''.test
	}
	
	override testToStringWithObjectRedefiningToStringInWollok() {
	}

	@Test
	def void testFlatMap() {
		'''
		assert.equals(#{1,2,3,4}, #{#{1,2}, #{1,3,4}}.flatten())
		assert.equals(#{1,2, 3}, #{#{1,2}, #{}, #{1,2, 3}}.flatten())
		assert.equals(#{}, #{}.flatten())
		assert.equals(#{}, #{#{}}.flatten())
		'''.test
	}
	
	@Test
	def void testConversions() {
		'''
		const set= #{1,2,3}
		assert.equals(#{1,2,3}, set.asSet())		
		const list = set.asList()
		assert.equals(3, list.size())
		[1,2,3].forEach{i=>assert.equals(list.contains(i))}
		'''.test
	}
	
	@Test
	override removeAll() {
		'''
		«instantiateCollectionAsNumbersVariable»
		numbers.removeAll(#{2, 10})
		assert.equals(#{22}, numbers)
		'''.test
	}
	
	@Test
	def void testEquals() {
		'''
		assert.equals(#{}, #{})
		assert.equals(#{1,2}, #{2,1})
		assert.equals(#{1,1,2,2}, #{1,2})
		'''.test
	}
	
	@Test
	def void testNotEquals() {
		'''
		assert.notEquals(#{}, #{1})
		assert.notEquals(#{1}, #{})
		assert.notEquals(#{1,2}, #{1})
		assert.notEquals(#{1,3}, #{1,2})
		'''.test
	}	
	
		@Test
	def void testEqualityWithOtherObjects(){
		'''
			assert.notEquals(2, #{})
			assert.notEquals(2, #{2})
			assert.notEquals(2, #{2,3,4})
			assert.notEquals(console, #{})
		'''.test
	}
	
}
