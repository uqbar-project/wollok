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
		"val numbers = new WList()
		numbers.add(22)
		numbers.add(2)
		numbers.add(10)"
	}
	
	override instantiateStrings() {
		"val strings = new WList(); \n #['hello', 'hola', 'bonjour', 'ciao', 'hi'].forEach[e| strings.add(e) ]"
	}
	
	@Test
	def void toStringOnEmptyCollection() {
		'''
		program p {
			val numbers = new WList()
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
	
	
}