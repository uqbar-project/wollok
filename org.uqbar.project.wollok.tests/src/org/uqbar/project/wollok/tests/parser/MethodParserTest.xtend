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
		'''.expectsSyntaxError("Missing () in method definition", false)
	}

	@Test
	def void FakePatternMatchingInParameter() {
		'''
		object pepita {
			method friends([]) {
				return true
			}
		}
		'''.expectsSyntaxError("Method definition: bad character in parameter. Don't use [", false)
	}

	@Test
	def void BadCharacterInParameter() {
		'''
		object pepita {
			method friends({}) {
				return true
			}
		}
		'''.expectsSyntaxError("Method definition: bad character in parameter. Don't use {", false)
	}

	@Test
	def void BadCharacterInParameter2() {
		'''
		object pepita {
			method friends(#2) {
				return true
			}
		}
		'''.expectsSyntaxError("Method definition: bad character in parameter. Don't use #", false)
	}

	@Test
	def void FourEqualsOperatorErrorMessage() {
		'''
		object pepita {
			var energia = 0
			method estaCansada() {
				return energia ==== 0
			}
		}
		'''.expectsSyntaxError("Bad message: ====", false)
	}

	@Test
	def void FourNotEqualsOperatorErrorMessage() {
		'''
		object pepita {
			var energia = 0
			method estaConEnergia() {
				return energia !=== 0
			}
		}
		'''.expectsSyntaxError("Bad message: !===", false)
	}

	@Test
	def void UnexistentMessageErrorMessage() {
		'''
		object pepita {
			var energia = 0
			method estaCansada() {
				return energia.esSiempreIgualA(0)
			}
		}
		'''.expectsNoSyntaxError
	}
	
}