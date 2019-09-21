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
		[1,2,3].forEach{i=>assert.that(list.contains(i))}
		'''.test
	}
	
	@Test
	def void testSetOfNumberSize() {
		'''
		const set = new Set()
		const a = 2
		const b = 1 + 1
		const c = 3
		set.add(a)
		set.add(b)
		set.add(c)
		assert.equals(2, set.size())
		assert.equals(set, #{a,c})
		assert.equals(#{a,c}, #{b,c})
		'''.test
	}
	
	@Test
	def void testSetOfStringSize() {
		'''
		const set = new Set()
		const a = "hola"
		const b = "ho" + "la"
		const c = "chau"
		set.add(a)
		set.add(b)
		set.add(c)
		assert.equals(2, set.size())
		assert.equals(set, #{a,c})
		assert.equals(#{a,c}, #{b,c})
		'''.test
	}
	
	@Test
	def void testSetOfBooleanSize() {
		'''
		const set = new Set()
		const a = true
		const b = !false
		const c = false
		set.add(a)
		set.add(b)
		set.add(c)
		assert.equals(2, set.size())
		assert.equals(set, #{a,c})
		assert.equals(#{a,c}, #{b,c})
		'''.test
	}
	
	@Test
	def void testSetOfListSize() {
		'''
		const set = #{[1,2,3],[5,6],[7,8],[1,2,3],[5,6]}
		assert.equals(3, set.size())
		'''.test
	}

	@Test
	def void testSetOfEmptyListSize() {
		'''
		const set = #{}
		const a = []
		const b = new List()
		set.add(a)
		set.add(b)
		assert.equals(1, set.size())
		assert.equals(set, #{a})
		assert.equals(#{a}, #{b})
		'''.test
	}
	
	@Test
	def void testSetOfSetSize() {
		'''
		const set = #{#{1,2,3},#{5,6},#{7,8},#{1,2,3},#{5,6}}
		assert.equals(3, set.size())
		'''.test
	}
	
	@Test
	def void testSetOfEmptySetSize() {
		'''
		const set = #{}
		const a = #{}
		const b = #{}
		set.add(a)
		set.add(b)
		assert.equals(1, set.size())
		assert.equals(set, #{a})
		assert.equals(#{a}, #{b})
		'''.test
	}
	
	@Test
	def void testSetOfDictionarySize() {
		'''
		const set = #{}
		const a = new Dictionary()
		const b = new Dictionary()
		const c = new Dictionary()
		c.put(1, "hola")
		set.add(a)
		set.add(b)
		set.add(c)
		assert.equals(2, set.size())
		assert.equals(set, #{a,c})
		assert.equals(#{a,c}, #{b,c})
		'''.test
	}

	@Test
	def void testSetOfPairSize() {
		'''
		const set = new Set()
		const a = new Pair(x = 1, y = 2)
		const b = new Pair(x = 1, y = 2)
		const c = new Pair(x = 3, y = 4)
		set.add(a)
		set.add(b)
		set.add(c)
		assert.equals(2, set.size())
		assert.equals(set, #{a,c})
		assert.equals(#{a,c}, #{b,c})
		'''.test
	}
	
	@Test
	def void testSetOfPositionSize() {
		'''
		const set = new Set()
		const a = new Position()
		const b = new Position()
		var c = new Position()
		c = c.up(2)
		set.add(a)
		set.add(b)
		set.add(c)
		assert.equals(2, set.size())
		assert.equals(set, #{a,c})
		assert.equals(#{a,c}, #{b,c})
		'''.test
	}
	
	@Test
	def void testSetOfUserDefinedClassSizeRedefiningEqualEqual() {
		'''
		class Animal {
			override method ==(otroAnimal) = self.nombre() == otroAnimal.nombre()
			method nombre()
		}
		
		class Perro inherits Animal {
			override method nombre() = "Firulais"
		}
		
		class Gato inherits Animal {
			override method nombre() = "Garfield"
		}
		
		test "issue 1771" {
			const set = new Set()
			const perro = new Perro()
			const otroPerro = new Perro()
			const gato = new Gato()
			set.add(perro)
			set.add(otroPerro)
			set.add(gato)
			assert.equals(2, set.size())
			assert.equals(set, #{perro,gato})
			assert.equals(#{perro,gato}, #{otroPerro,gato})
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testSetOfUserDefinedClassSizeRedefiningEquals() {
		'''
		class Animal {
			override method equals(otroAnimal) = self.nombre() == otroAnimal.nombre()
			method nombre()
		}
		
		class Perro inherits Animal {
			override method nombre() = "Firulais"
		}
		
		class Gato inherits Animal {
			override method nombre() = "Garfield"
		}
		
		test "issue 1771" {
			const set = new Set()
			const perro = new Perro()
			const otroPerro = new Perro()
			const gato = new Gato()
			set.add(perro)
			set.add(otroPerro)
			set.add(gato)
			assert.equals(2, set.size())
			assert.equals(set, #{perro,gato})
			assert.equals(#{perro,gato}, #{otroPerro,gato})
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testSetOfListAsSetConversion() {
		'''
		var list = new List()
		list.addAll([1,2,3])
		assert.equals(1, #{list,[1,2,3]}.asSet().size())
		'''.test
	}
	
	@Test
	def void testSetOfSetsAsSetConversion() {
		'''
		var set = new Set()
		set.addAll([1,2,3])
		assert.equals(1, #{set, #{1,2,3}}.asSet().size())
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
