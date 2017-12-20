package org.uqbar.project.wollok.tests.interpreter

import org.junit.After
import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.interpreter.nativeobj.DecimalsNotAllowedCoercingStrategy
import org.uqbar.project.wollok.interpreter.nativeobj.WollokNumbersPreferences

/**
 * @author dodain
 */
class NumbersConfigurationDecimalNotAllowedStrategyTestCase extends AbstractWollokInterpreterTestCase {
	
	@Before
	def void init() {
		WollokNumbersPreferences.instance => [
			numberCoercingStrategy = new DecimalsNotAllowedCoercingStrategy
			decimalPositions = 2	
		]
	}
	
	@After
	def void end() {
		WollokNumbersPreferences.instance.initializeForTests
	}
	
	@Test
	def void addSeveralDecimals() {
		'''
		assert.equals(5.21, 3.99 + 1.22)
		'''.test
	}

	@Test
	def void addSeveralDecimalsNotAllowed() {
		'''
		assert.throwsExceptionWithMessage("Number 3.991 must have 2 decimal positions or less", { 3.991 + 1.22 })
		'''.test
	}

	@Test
	def void addSeveralDecimalsNotAllowed2() {
		'''
		assert.throwsExceptionWithMessage("Number 1.223 must have 2 decimal positions or less", { 3.99 + 1.223 })
		'''.test
	}

	@Test
	def void subtractSeveralDecimals() {
		'''
		assert.throwsExceptionWithMessage("Number 3.991 must have 2 decimal positions or less", { 3.991 - 1.22 })
		'''.test
	}
	
	@Test
	def void subtractSeveralDecimals2() {
		'''
		assert.throwsExceptionWithMessage("Number 1.223 must have 2 decimal positions or less", { 3.99 - 1.223 })
		'''.test
	}

	@Test
	def void multiplySeveralDecimals() {
		'''
		assert.equals(9.36, 4.22 * 2.22)
		'''.test
	}

	@Test
	def void divideSeveralDecimals() {
		'''
		assert.equals(1.9, 4.22 / 2.22)
		'''.test
	}
	
	@Test
	def void listGet() {
		'''
		assert.throwsExceptionWithMessage("Number 1.99999 must have 2 decimal positions or less", { ["saludo", "hola", "jua"].get(1.99999) })
		'''.test
	}
	
	@Test
	def void range() {
		'''
		assert.throwsExceptionWithMessage("Number 2.9999 must have 2 decimal positions or less", { ((1.1)..(2.9999)).asList() })
		'''.test
	}
	
}