package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.ListTestCase
import org.uqbar.project.wollok.tests.interpreter.CollectionTestCase

/**
 * @author jfernandes
 */
// the inheritance needs to be reviewed if we add list specific tests it won't work here
class SetTest extends CollectionTestCase {
	
	override instantiateCollectionAsNumbersVariable() {
		"val numbers = #{22, 2, 10}"
	}
	
	@Test
	def void testSizeWithDuplicates() {
		'''
		program p {
			val numbers = #{ 23, 2, 1, 1, 1 }		
			assert.equals(3, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testSizeAddingDuplicates() {
		'''
		program p {
			val numbers = #{ 23, 2, 1, 1, 1 }
			numbers.add(1)
			numbers.add(1)		
			assert.equals(3, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testSizeAddingDuplicatesWithAddAll() {
		'''
		program p {
			val numbers = #{ 23, 2, 1, 1, 1 }
			numbers.add(#{1, 1, 1, 1, 4})
			assert.equals(4, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	override def void testToString() {
		'''
		program p {
			val a = #{23, 2, 2}
			val s = a.toString()
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
			val set= #{1,2,3}
			assert.equals(#{1,2,3}, set.asSet())
			
			val list = set.asList()
			assert.equals(3, list.size())
			#[1,2,3].forEach[i|assert.equals(list.contains(i))]
		}'''.interpretPropagatingErrors
	}
}
