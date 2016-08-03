package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.ListTestCase

/**
 * Tests the wollok List class included in the Wollok SDK.
 * 
 * @author jfernandes
 * @author PalumboN
 * @author tesonep
 */
class ListTest extends ListTestCase {
	
	override instantiateCollectionAsNumbersVariable() {
		"const numbers = new List()
		numbers.add(22)
		numbers.add(2)
		numbers.add(10)"
	}
	
	override instantiateStrings() {
		"const strings = new List(); " + System.lineSeparator + " ['hello', 'hola', 'bonjour', 'ciao', 'hi'].forEach{e=> strings.add(e) }"
	}
	
	@Test
	def void toStringOnEmptyCollection() {
		'''
		const numbers = new List()
		assert.equals("[]", numbers.toString())
		'''.test
	}
	
	@Test
	def void identityOnMap() {
		'''
		«instantiateCollectionAsNumbersVariable»
		const strings = numbers.map{e=> e.toString()}
		
		assert.notEquals(numbers.identity(), strings.identity())
		
		assert.that(strings.contains("22"))
		assert.that(strings.contains("2"))
		'''.test
	}
	
	@Test
	def void testContainsWithComplexObjects() {
		'''
		object o1 {}
		object o2 {}
			
		program p {
			const list = [o1, o2]
			
			assert.that(list.contains(o1))
			assert.that(list.contains(o2))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testAsListConversion() {
		'''
		const list = [1,2,3]
		assert.equals([1,2,3], list.asList())
		'''.test
	}
	
		@Test
	def void testAsSetConversion() {
		'''
		const set = #{}
		set.add(1)
		set.add(2)
		set.add(3)
		
		assert.equals(set, set.asSet())
		'''.test
	}
	
	@Test
	def void testFirstAndHead() {
		'''
		const list = [1,2,3]		
		assert.equals(1, list.first())
		assert.equals(1, list.head())
		'''.test
	}

	@Test
	def void testSortBy() {
		''' 
		const list = [1,2,3]		
		assert.equals([3,2,1], list.sortBy({x,y => x > y}))
		assert.that(list === list.sortBy({x,y => x < y}))
		'''.test
	}
	
	@Test
	def void testSortedBy() {
		'''
		const list = [1,2,3]
		assert.equals([3,2,1], list.sortedBy({x,y => x > y}))
		assert.notThat(list === list.sortedBy({x,y => x < y}))
		'''.test
	}
	
	
	@Test
	def void testEquals() {
		'''
		assert.equals([], [])
		assert.equals([1,2,1], [1,2,1])
		'''.test
	}
	
	@Test
	def void testNotEquals() {
		'''
		assert.notEquals([], [1])
		assert.notEquals([1], [])
		assert.notEquals([1,2], [1])
		assert.notEquals([1,2], [2,1])
		assert.notEquals([1,3], [1,2])
		'''.test
	}
	
	@Test
	def void testEqualityWithOtherObjects(){
		'''
			assert.notEquals(2, [])
			assert.notEquals(2, [2])
			assert.notEquals(2, [2,3,4])
			assert.notEquals(console, [])
		'''.test
	}
}
