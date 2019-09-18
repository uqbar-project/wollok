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
		assert.equals(1, [1, 2/2].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfStringAsSetConversion() {
		'''
		assert.equals(1, ["hola", "ho" + "la"].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfBooleanAsSetConversion() {
		'''
		assert.equals(1, [true, 2 == 2].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfDateAsSetConversion() {
		'''
		assert.equals(1, [new Date(day=1, month=4, year=2018), new Date(day=1, month=4, year=2018)].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfListAsSetConversion() {
		'''
		var list = new List()
		list.addAll([1,2,3])
		assert.equals(1, [list, [1,2,3]].asSet().size())
		'''.test
	}

	@Test
	def void testListOfEmptyDictionaryAsSetConversion() {
		'''
		assert.equals(1, [new Dictionary(), new Dictionary()].asSet().size())
		'''.test
	}

	@Test
	def void testListOfNonEmptyDictionaryAsSetConversion() {
		'''
		const firstDictionary = new Dictionary()
		firstDictionary.put(1, "hola")
		firstDictionary.put(2, "chau")
		const secondDictionary = new Dictionary()
		secondDictionary.put(1, "hola")
		secondDictionary.put(2, "chau")
		assert.equals(1, [firstDictionary, secondDictionary].asSet().size())
		'''.test
	}
		
	@Test
	def void testListOfPairAsSetConversion() {
		'''
		assert.equals(1, [new Pair(1,2), new Pair(1,2)].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfPositionAsSetConversion() {
		'''
		assert.equals(1, [new Position() ,new Position()].asSet().size())
		'''.test
	}
	
	@Test
	def void testListOfUserDefinedClassAsSetConversionRedefiningEqualEqual() {
		'''
		class C {
			override method ==(other) = self.kindName() == other.kindName()
		}
			
		class D {
			override method ==(other) = self.kindName() == other.kindName()
		}
		
		test "issue 1771" {
			assert.equals(2, [new C(), new D(), new C()].asSet().size())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testListOfUserDefinedClassAsSetConversionRedefiningEquals() {
		'''
		class C {
			override method equals(other) = self.kindName() == other.kindName()
		}
			
		class D {
			override method equals(other) = self.kindName() == other.kindName()
		}
		
		test "issue 1771" {
			assert.equals(2, [new C(), new D(), new C()].asSet().size())
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
		const list = [1, 3, 1, 5, 1, 3, 2, 5]
		const result = [1, 3, 5, 2]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(4, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i=> assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfStringWithoutDuplicates() {
		'''
		const list = ["amigo", "carpeta", "beca", "amigo", "carpeta"]
		const result = ["amigo", "carpeta", "beca"]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(3, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfDateWithoutDuplicates() {
		'''
		const list = [new Date(day=22, month=9, year=2020), new Date(day=1, month=4, year=2018), new Date(day=22, month=9, year=2020)]
		const result = [new Date(day=22, month=9, year=2020), new Date(day=1, month=4, year=2018)]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(2, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		'''.test
	}
	
	@Test
	def void testListOfBooleanWithoutDuplicates() {
		'''
		assert.equals(1, [true,!false].withoutDuplicates().size())
		'''.test
	}
	
	//  ESTE TEST FALLA (Expected [3] but found [4]). [6,7,8,9,22,12] estaría quedando duplicado luego del withoutDuplicates.
//	@Test
//	def void testListOfListWithoutDuplicates() {
//		'''
//		var lista = new List()
//		lista.addAll([1,2,3])
//		const list = [[6,7,8,9,22,12], [1,2,3], [1,2,3,4,5], [1,2,3], [6,7,8,9,22,12]]
//		assert.equals(3, list.withoutDuplicates().size())
//		assert.equals([[6,7,8,9,22,12], [1,2,3], [1,2,3,4,5] ], list.withoutDuplicates())
//		'''.test
//	}
	
	
//  ESTE TEST FALLA (Expected [3] but found [4]).  #{1,44,55,33,27,12} estaría quedando duplicado luego del withoutDuplicates.

//	@Test
//	def void testListOfSetWithoutDuplicates() {
//		'''
//		var set = new Set()
//		set.addAll([1,2,3])
//		const list = [#{1,44,55,33,27,12}, set, #{1,2,3,4,5,6}, #{1,2,3}, #{1,2,3,4,5,6}, #{1,44,55,33,27,12}]
//		assert.equals(3, list.withoutDuplicates().size())
//		assert.equals([#{1,44,55,33,27,12}, #{1,2,3}, #{1,2,3,4,5,6}], list.withoutDuplicates())
//		'''.test
//	}
	
	@Test
	def void testListOfDictionaryWithoutDuplicates() {
		'''
		assert.equals(1, [new Dictionary(), new Dictionary()].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfPairWithoutDuplicates() {
		'''
		assert.equals(1, [new Pair(1,2), new Pair(1,2)].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfPositionWithoutDuplicates() {
		'''
		assert.equals(1, [new Position(), new Position()].withoutDuplicates().size())
		'''.test
	}
	
	@Test
	def void testListOfUserDefinedClassWithoutDuplicatesRedefiningEqualEqual() {
		'''
		class C {
			override method ==(other) = self.kindName() == other.kindName()
		}
		
		class D {
			override method ==(other) = self.kindName() == other.kindName()
		}
		
		test "issue 1771" {
			const list = [new D(), new C(), new D(), new C()]
			const result = [new D(), new C()]
			const withoutDuplicates = list.withoutDuplicates()
			assert.equals(2, withoutDuplicates.size())
			(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testListOfUserDefinedClassWithoutDuplicatesRedefiningEquals() {
		'''
		class C {
			override method equals(other) = self.kindName() == other.kindName()
		}
				
		class D {
			override method equals(other) = self.kindName() == other.kindName()
		}
		
		test "issue 1771" {
			const list = [new D(), new C(), new D(), new C()]
			const result = [new D(), new C()]
			const withoutDuplicates = list.withoutDuplicates()
			assert.equals(2, withoutDuplicates.size())
			(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testListOfDifferentTypesWithoutDuplicates() {
		'''
		const list = [2, "hola", true, 2, "casa", "hola", 1]
		const result = [2, "hola", true, "casa", 1]
		const withoutDuplicates = list.withoutDuplicates()
		assert.equals(5, withoutDuplicates.size())
		(0..result.size()-1).forEach{ i => assert.that(withoutDuplicates.get(i).equals(result.get(i))) }
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
