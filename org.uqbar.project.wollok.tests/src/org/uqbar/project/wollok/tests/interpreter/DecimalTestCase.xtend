package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * 
 * @author dodain
 */
class DecimalTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void roundUp() {
		'''
		assert.equals(14, 13.224.roundUp())
		assert.equals(16, 15.942.roundUp())
		assert.equals(15, 15.0.roundUp())
		'''.test
	}
	
	@Test
	def void roundUpDecimals() {
		'''
		assert.equals(1.224, 1.223445.roundUp(3))
		assert.equals(14.617, 14.6165.roundUp(3))
		assert.equals(14.6165, 14.6165.roundUp(6))
		'''.test
	}
	
	@Test
	def void truncate() {
		'''
		assert.equals(1.223, 1.223445.truncate(3))
		assert.equals(14.616, 14.6165.truncate(3))
		assert.equals(14.61, 14.6165.truncate(2))
		assert.equals(14.61, 14.61.truncate(3))
		'''.test
	}

	@Test
	def void roundUpNegativeDecimalsThrowsError() {
		'''
		assert.throwsExceptionWithMessage("Cannot set new scale with -3 decimals", { 1.223445.truncate(-3) })
		assert.throwsExceptionWithMessage("Cannot set new scale with -3 decimals", { 1.223445.roundUp(-3) })
		'''.test
	}
	
}