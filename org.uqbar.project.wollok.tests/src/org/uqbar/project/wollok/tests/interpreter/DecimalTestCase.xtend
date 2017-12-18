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
		assert.equals(-14, -13.224.roundUp())
		assert.equals(16, 15.942.roundUp())
		assert.equals(15, 15.0.roundUp())
		assert.equals(-15, -15.0.roundUp())
		'''.test
	}

	@Test
	def void roundUpDecimals() {
		'''
		assert.equals(1.224, 1.223445.roundUp(3))
		assert.equals(-1.224, -1.223445.roundUp(3))
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
		assert.throwsExceptionWithMessage("Scale must be an integer and positive value", { 1.223445.truncate(-3) })
		assert.throwsExceptionWithMessage("Scale must be an integer and positive value", { 1.223445.roundUp(-3) })
		'''.test
	}

	@Test
	def void roundUpAlphabeticDecimalsThrowsError() {
		'''
		assert.throwsExceptionWithMessage("Cannot convert parameter A to type wollok.lang.Number", { 1.223445.truncate("A") })
		assert.throwsExceptionWithMessage("Cannot convert parameter B to type wollok.lang.Number", { 1.223445.roundUp("B") })
		'''.test
	}
	
}