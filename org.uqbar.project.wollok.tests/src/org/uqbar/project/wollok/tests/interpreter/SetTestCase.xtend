package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

/**
 * @author jfernandes
 */
class SetTestCase extends CollectionTestCase {
	
	@Test
	def void unionWithEmptySet() {
		'''
		program p {
			const aSet = #{1, 2, 3}
			
			assert.equals(aSet, aSet.union(#{}))
			assert.equals(aSet, #{}.union(aSet))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void unionWithNonEmptySets() {
		'''
		program p {
			const aSet = #{1, 2, 3}
			const anotherSet = #{3, 4, 5}
			const unionSet = #{1, 2, 3, 4, 5}
			
			assert.equals(aSet, aSet.union(aSet))
			assert.equals(unionSet, aSet.union(anotherSet))
			assert.equals(unionSet, anotherSet.union(aSet))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void intersectionWithEmptySet() {
		'''
		program p {
			const aSet = #{1, 2, 3}
			
			assert.equals(#{}, aSet.intersection(#{}))
			assert.equals(#{}, #{}.intersection(aSet))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void intersectionWithNonEmptySets() {
		'''
		program p {
			const aSet = #{1, 2, 3}
			const anotherSet = #{3, 4, 5}
			const intersectionSet = #{3}
			
			assert.equals(aSet, aSet.intersection(aSet))
			assert.equals(intersectionSet, aSet.intersection(anotherSet))
			assert.equals(intersectionSet, anotherSet.intersection(aSet))
		}'''.interpretPropagatingErrors
	}

	@Test
	def void differenceWithEmptySet() {
		'''
		program p {
			const aSet = #{1, 2, 3}
			
			assert.equals(aSet, aSet.difference(#{}))
			assert.equals(#{}, #{}.difference(aSet))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void differenceWithNonEmptySets() {
		'''
		program p {
			const aSet = #{1, 2, 3}
			const anotherSet = #{3, 4, 5}
			
			assert.equals(#{}, aSet.difference(aSet))
			assert.equals(#{1, 2}, aSet.difference(anotherSet))
			assert.equals(#{4, 5}, anotherSet.difference(aSet))
		}'''.interpretPropagatingErrors
	}
}