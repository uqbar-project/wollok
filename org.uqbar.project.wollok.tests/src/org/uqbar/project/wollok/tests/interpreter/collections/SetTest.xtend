package org.uqbar.project.wollok.tests.interpreter.collections

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.ListTestCase

/**
 * @author jfernandes
 */
// the inheritance needs to be reviewed if we add list specific tests it won't work here
class SetTest extends ListTestCase {
	
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
			assert.equals("#{2, 23}", a.toString())
		}'''.interpretPropagatingErrors
	}
	
	override testToStringWithObjectRedefiningToStringInWollok() {
	}
	
}