package org.uqbar.project.wollok.tests.parser

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/** 
 * Test representative error messages for constructors
 * @author dodain
 */
class ReferencesParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void referencesAfterMethodsInWko() {
		'''
		object pepita {
			method volar() { energia = energia - 20 }
			var energia = 0
		}
		'''.expectsSyntaxError("You should declare references before methods and tests.", false)
	}

	@Test
	def void referencesAfterMethodsInClass() {
		'''
		class Ave {
			method volar() { energia = energia - 20 }
			var energia = 0
		}
		'''.expectsSyntaxError("You should declare references before methods and tests.", false)
	}

	@Test
	def void referencesAfterMethodsInDescribe() {
		'''
		describe "group of tests" {
			method volar() { energia = energia - 20 }
			var energia = 0
			test "simple test" {
				assert.equals(1, 1)
			}
		}
		'''.expectsSyntaxError("You should declare references before methods and tests.", false)
	}

	@Test
	def void referencesAfterTestsInDescribe() {
		'''
		describe "group of tests" {
			method volar() { energia = energia - 20 }
			test "simple test" {
				assert.equals(1, 1)
			}
			var energia = 0
		}
		'''.expectsSyntaxError("You should declare references before methods and tests.", false)
	}

}