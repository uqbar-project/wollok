package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * @author matifreyre
 */
class SetTestCase extends CollectionTestCase {
	
	@Test
	def void unionWithEmptySet() {
		'''
		const aSet = #{1, 2, 3}
		
		assert.equals(aSet, aSet.union(#{}))
		assert.equals(aSet, #{}.union(aSet))
		'''.test
	}
	
	@Test
	def void unionWithNonEmptySets() {
		'''
		const aSet = #{1, 2, 3}
		const anotherSet = #{3, 4, 5}
		const unionSet = #{1, 2, 3, 4, 5}
		
		assert.equals(aSet, aSet.union(aSet))
		assert.equals(unionSet, aSet.union(anotherSet))
		assert.equals(unionSet, anotherSet.union(aSet))
		'''.test
	}
	
	@Test
	def void intersectionWithEmptySet() {
		'''
		const aSet = #{1, 2, 3}
		
		assert.equals(#{}, aSet.intersection(#{}))
		assert.equals(#{}, #{}.intersection(aSet))
		'''.test
	}
	
	@Test
	def void intersectionWithNonEmptySets() {
		'''
		const aSet = #{1, 2, 3}
		const anotherSet = #{3, 4, 5}
		const intersectionSet = #{3}
		
		assert.equals(aSet, aSet.intersection(aSet))
		assert.equals(intersectionSet, aSet.intersection(anotherSet))
		assert.equals(intersectionSet, anotherSet.intersection(aSet))
		'''.test
	}

	@Test
	def void differenceWithEmptySet() {
		'''
		const aSet = #{1, 2, 3}
			
		assert.equals(aSet, aSet.difference(#{}))
		assert.equals(#{}, #{}.difference(aSet))
		'''.test
	}
	
	@Test
	def void differenceWithNonEmptySets() {
		'''
		const aSet = #{1, 2, 3}
		const anotherSet = #{3, 4, 5}
		
		assert.equals(#{}, aSet.difference(aSet))
		assert.equals(#{1, 2}, aSet.difference(anotherSet))
		assert.equals(#{4, 5}, anotherSet.difference(aSet))
		'''.test
	}
	
	@Test
	def void equalityCaseTrue() {
		'''
		assert.equals(#{'Hello'}, #{'Hello'})
		assert.equals(#{5, 4, 9}, #{4, 5, 9})
		assert.equals(#{true}, #{true})
		assert.equals(#{}, #{})
		'''.test		
	}
			
	@Test
	def void equalityCaseFalse() {
		'''
			assert.notEquals(#{'Hello'}, #{'Hellou'})
			assert.notEquals(#{5, 4, 9}, #{4, 5, 3})
			assert.notEquals(#{4, 5, 9}, [4, 5, 9])
		'''.test		
	}
	
	@Test
	def void elementsAreUnique() {
		'''
		assert.equals(2, #{"melon", "tomate", "melon"}.size())
		assert.equals(2, #{5, 7, 7, 5, 5, 5, 7, 7, 5, 5, 7}.size())
		'''.test
	} 	
	
}