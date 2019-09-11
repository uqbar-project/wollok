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
	def void testListOfNumberAsSetConversion() {
		'''
		assert.equals(1, [1,1].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfStringAsSetConversion() {
		'''
		assert.equals(1, ["hola","hola"].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfBooleanAsSetConversion() {
		'''
		assert.equals(1, [true,true].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfDateAsSetConversion() {
		'''
		const a = new Date(day=12, month=5, year=2019)
		const b = new Date(day=12, month=5, year=2019)
		assert.equals(1,[a,b].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfListAsSetConversion() {
		'''
		assert.equals(1, [[1,2,3],[1,2,3]].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfDictionaryAsSetConversion() {
		'''
		const dictionary = new Dictionary()
		assert.equals(1, [dictionary,dictionary].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfPairAsSetConversion() {
		'''
		const pair = new Pair(1,2)
		assert.equals(1, [pair,pair].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfPositionAsSetConversion() {
		'''
		const a = new Position()
		const b = new Position()
		assert.equals(1, [a,b].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfUserDefinedClassAsSetConversion() {
		'''
		class MiClase {}
		program a {
			const miClase = new MiClase()
			assert.equals(1, [miClase,miClase].asSet().size())
		}
		
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testListOfDifferentTypesAsSetConversion() {
		'''
			var list = []
			list.add(1)
			list.add("1")
			list.add(true)
			list.add("1")
			list.add(new Date())
			list.add(true)
			list.add(new Date().toString())
			list.add("true")
			list.add(1)
			list.add(new Date())
			assert.equals(6, list.asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfNumberWithoutDuplicates() {
		'''
		assert.equals(1, [1,1].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfStringWithoutDuplicates() {
		'''
		assert.equals(1, ["hola","hola"].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfDateWithoutDuplicates() {
		'''
		const a = new Date(day=1, month=4, year=2018)
		const b = new Date(day=1, month=4, year=2018)
		assert.equals(1, [a,b].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfBooleanWithoutDuplicates() {
		'''
		assert.equals(1, [true,!false].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfListWithoutDuplicates() {
		'''
		assert.equals(1, [[1,2,3],[1,2,3]].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfSetWithoutDuplicates() {
		'''
		assert.equals(1, [#{1,2,3},#{1,2,3}].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfDictionaryWithoutDuplicates() {
		'''
		const a = new Dictionary()
		assert.equals(1, [a,a].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfPairWithoutDuplicates() {
		'''
		const a = new Pair(1,2)
		assert.equals(1, [a,a].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfPositionWithoutDuplicates() {
		'''
		const a = new Position()
		const b = new Position()
		assert.equals(1, [a,b].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfUserDefinedClassWithoutDuplicates() {
		'''
		class MiClase {}
		program a {
			const a = new MiClase()
			assert.equals(1, [a,a].withoutDuplicates().size())
		}
		
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testListOfDifferentTypesWithoutDuplicates() {
		'''
		const list = new List()
		list.add(1)
		list.add("hola")
		list.add(true)
		list.add(1)
		list.add("hola")
		assert.equals(3, list.withoutDuplicates().size())
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
		var list = [1,2,3]
		list.sortBy({x,y => x > y})
		assert.equals([3,2,1], list)
		list.sortBy({x,y => x < y})
		assert.equals([1,2,3], list)
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
