package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.interpreter.nativeobj.TruncateDecimalsCoercingStrategy
import org.uqbar.project.wollok.interpreter.nativeobj.WollokNumbersPreferences
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test

/**
 * @author dodain
 */
class NumbersConfigurationTruncateStrategyTestCase extends AbstractWollokInterpreterTestCase {
	
	@BeforeEach
	def void init() {
		WollokNumbersPreferences.instance.numberCoercingStrategy = new TruncateDecimalsCoercingStrategy
	}
	
	@AfterEach
	def void end() {
		WollokNumbersPreferences.instance => [
			decimalPositions = WollokNumbersPreferences.DECIMAL_POSITIONS_DEFAULT
			numberCoercingStrategy = WollokNumbersPreferences.NUMBER_COERCING_STRATEGY_DEFAULT
			numberPrintingStrategy = WollokNumbersPreferences.NUMBER_PRINTING_STRATEGY_DEFAULT
		]
	}
	
	@Test
	def void addSeveralDecimals() {
		'''
		assert.equals(4, 3.000004 + 1.000006)
		assert.equals(4, 3.000002 + 1.000006)
		assert.equals(4, 3.000002 + 1.000002)
		'''.test
	}

	@Test
	def void subtractSeveralDecimals() {
		'''
		assert.equals(0, 4.000004 - 4.000006)
		assert.equals(0, 4.000007 - 4.000006)
		assert.equals(2, 3.000002 - 1.000001)
		assert.equals(2, 3.000002 - 1.000006)
		assert.equals(1.99978, 3.000002 - 1.000222)
		'''.test
	}

	@Test
	def void multiplySeveralDecimals() {
		'''
		assert.equals(8, 4.00000000001 * 2.000000000003)
		assert.equals(0, 4.00222222222222000000001 * 0)
		assert.equals(4.00270, 4.00222222222222000000001 * 1.00012)
		assert.equals(4.00414, 4.00222522222222000000001 * 1.00048)
		'''.test
	}
	
	@Test
	def void listGet() {
		'''
		assert.equals("hola", ["saludo", "hola", "jua"].get(1.99999))
		'''.test
	}
	
	@Test
	def void range() {
		'''
		assert.equals([1, 2], ((1.1)..(2.9999)).asList())
		'''.test
	}
	
}