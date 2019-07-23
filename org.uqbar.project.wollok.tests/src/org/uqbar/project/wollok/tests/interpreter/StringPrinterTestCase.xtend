package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Tests for String Printer
 * 
 * @author dodain
 */
class StringPrinterTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void printingNull() {
		'''
		const printer = new StringPrinter()
		printer.println(null)
		assert.equals("null", printer.getBuffer().trim())
		'''.test
	}
	
	@Test	
	def void printingSomethingNotNullUsesToStringMethod() {
		'''
		const pepita = object {
			var energia = 10
			override method toString() = "pepita"
		}
		
		const printer = new StringPrinter()
		printer.println(pepita)
		assert.equals("pepita", printer.getBuffer().trim())
		'''.test
	}

}