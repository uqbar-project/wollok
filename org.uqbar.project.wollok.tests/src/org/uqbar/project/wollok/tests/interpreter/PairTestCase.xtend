package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class PairTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void smokeTest() {
		'''
		const pair = new Pair(1, 1)
		assert.equals(pair, pair)
		'''.test
	}
	
	@Test
	def void testNewContructor() {
		'''
		const pair = new Pair(1, 2)
		assert.equals(1, pair.x())
		assert.equals(2, pair.y())
		'''.test
	}
	
	@Test
	def void testArrowContructor() {
		'''
		const pair = 1->2
		assert.equals(1, pair.x())
		assert.equals(2, pair.y())
		'''.test
	}
	
	@Test
	def void testXGetter() {
		'''
		const pair = "1"->2
		assert.equals("1", pair.x())
		'''.test
	}
	
	@Test
	def void testYGetter() {
		'''
		const pair = 1->"2"
		assert.equals("2", pair.y())
		'''.test
	}
	
	@Test
	def void testXSetterThrowsCannotModifyConstantPropertyException() {
		'''
		const pair = 1->2
		assert.throwsExceptionWithMessage("Cannot modify constant property x", { pair.x(10) })
		'''.test
	}
	
	@Test
	def void testYSetterThrowsCannotModifyConstantPropertyException() {
		'''
		const pair = 1->2
		assert.throwsExceptionWithMessage("Cannot modify constant property y", { pair.y(20) })
		'''.test
	}
	
	@Test
	def void testKeyGetter() {
		'''
		const pair = 10->20
		assert.equals(10, pair.key())
		'''.test
	}
	
	@Test
	def void testValueGetter() {
		'''
		const pair = 10->20
		assert.equals(20, pair.value())
		'''.test
	}
	
	@Test
	def void testKeySetterThrowsMessageNotUnderstoodException() {
		'''
		const pair = 1->2
		assert.throwsExceptionWithType(new MessageNotUnderstoodException(), { pair.key(10) })
		'''.test
	}
	
	@Test
	def void testValueSetterThrowsMessageNotUnderstoodException() {
		'''
		const pair = 1->2
		assert.throwsExceptionWithType(new MessageNotUnderstoodException(), { pair.value(20) })
		'''.test
	}
	
	@Test
	def void testToStringRepresentation() {
		'''
		const pair = 10->20
		assert.equals("10 -> 20", pair.toString())
		'''.test
	}
	
	@Test
	def void testShortDescriptionRepresentation() {
		'''
		const pair = 10->20
		assert.equals("10 -> 20", pair.shortDescription())
		'''.test
	}
}