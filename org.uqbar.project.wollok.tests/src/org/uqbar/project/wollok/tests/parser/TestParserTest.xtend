package org.uqbar.project.wollok.tests.parser

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/** 
 * Test representative error messages for tests
 * @author dodain
 */
class TestParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testsNotAllowedInWko() {
		'''
		object pepita {
			var energia = 0
			test "nothing to do here" { }
			method volar() { energia = energia - 20 }
		}
		'''.expectSyntaxError("Tests are not allowed in object definition.", false)
	}

	@Test
	def void testsNotAllowedInWko2() {
		'''
		object pepita {
			var energia = 0
			method volar() { energia = energia - 20 }
			test "nothing to do here" {
				assert.equals(1, 1)
			}
		}
		'''.expectSyntaxError("Tests are not allowed in object definition.", false)
	}

	@Test
	def void testsNotAllowedInClass() {
		'''
		class Ave {
			var energia = 0
			test "nothing to do here" { }
			method volar() { energia = energia - 20 }
		}
		'''.expectSyntaxError("Tests are not allowed in class definition.", false)
	}

	@Test
	def void testsNotAllowedInClass2() {
		'''
		class Ave {
			var energia = 0
			method volar() { energia = energia - 20 }
			test "nothing to do here" { 
				assert.equals(1, 1)
			}
		}
		'''.expectSyntaxError("Tests are not allowed in class definition.", false)
	}

	@Test
	def void nestedTestsNotAllowed() {
		'''
		test "parent test" {
			var energia = 0
			test "nothing to do here" { 
				assert.equals(1, 1)
			}
		}
		'''.expectSyntaxError("Tests are not allowed in this definition.", false)
	}

	@Test
	def void constructorsNotAllowedInProgram() {
		'''
		program abc {
			const four = 4
			four.even()
			test "nothing to do here" { 
				assert.equals(1, 1)
			}
		}
		'''.expectSyntaxError("Tests are not allowed in this definition.")
	} 

}