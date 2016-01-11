package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.ListTestCase

/**
 * Tests the wollok List class included in the Wollok SDK.
 * 
 * @author jfernandes
 */
class ListTest extends ListTestCase {
	
	override instantiateCollectionAsNumbersVariable() {
		"val numbers = new List()
		numbers.add(22)
		numbers.add(2)
		numbers.add(10)"
	}
	
	override instantiateStrings() {
		"val strings = new List(); \n #['hello', 'hola', 'bonjour', 'ciao', 'hi'].forEach[e| strings.add(e) ]"
	}
	
	@Test
	def void toStringOnEmptyCollection() {
		'''
		program p {
			val numbers = new List()
			assert.equals("#[]", numbers.toString())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void identityOnMap() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			
			val strings = numbers.map[e| e.toString()]
			
			assert.notEquals(numbers.identity(), strings.identity())
			
			assert.that(strings.contains("22"))
			assert.that(strings.contains("2"))
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testContainsWithComplexObjects() {
		'''
		object o1 {}
		object o2 {}
			
		program p {
			val list = #[o1, o2]
			
			assert.that(list.contains(o1))
			assert.that(list.contains(o2))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testConversions() {
		'''
		program p {
			val list = #[1,2,3]
			
			assert.equals(#[1,2,3], list.asList())
			assert.equals(#{1,2,3}, list.asSet())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testFirstAndHead() {
		'''
		program p {
			val list = #[1,2,3]
			
			assert.equals(1, list.first())
			assert.equals(1, list.head())
		}'''.interpretPropagatingErrors
	}
}