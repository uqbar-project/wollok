package org.uqbar.project.wollok.tests.parser

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/** 
 * Test representative error messages for methods
 * @author dodain
 */
class MethodParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void missingParenthesesInMethod() {
		'''
		object pepita {
			method energiaDefault = 2
		}
		'''.expectSyntaxError("Missing () in method definition", false)
	}

}