package org.uqbar.project.wollok.tests.parser

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Ignore

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

	@Test
	def void FakePatternMatchingInParameter() {
		'''
		object pepita {
			method friends([]) {
				return true
			}
		}
		'''.expectSyntaxError("Method definition: bad character in parameter. Don't use [", false)
	}

	@Test
	def void BadCharacterInParameter() {
		'''
		object pepita {
			method friends({}) {
				return true
			}
		}
		'''.expectSyntaxError("Method definition: bad character in parameter. Don't use {", false)
	}

	@Test
	def void BadCharacterInParameter2() {
		'''
		object pepita {
			method friends(#2) {
				return true
			}
		}
		'''.expectSyntaxError("Method definition: bad character in parameter. Don't use #", false)
	}

	@Test
	@Ignore // until we give a try to a different syntax in WMemberFeatureCall
	def void MissingSelfInMessage() {
		'''
		object pepita {
			var energia = 0
			var vuelaEstaDistancia = 0
			method estaEnElRango() = true
			method distanciaAVolar() {
				estaEnElRango()
				//if (estaEnElRango()){
				//	vuelaEstaDistancia=(energia/5)+10
				//}
				//else{
				//	vuelaEstaDistancia=energia/5
				//}
				//return vuelaEstaDistancia
			}
		}
		'''.expectSyntaxError("Bad character in method definition: don't use [", false)
	}
}