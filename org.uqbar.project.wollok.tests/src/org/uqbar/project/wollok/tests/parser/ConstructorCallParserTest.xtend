package org.uqbar.project.wollok.tests.parser

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/** 
 * Test representative error messages for constructors calls
 * @author dodain
 */
class ConstructorCallParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void constructorsNotAllowedInObjects() {
		'''
		object wollok {
			method perro() {
				return new Perro( nombre = "firulais", edad = 12, 23, 30, 50 )
			}
		}
		
		class Perro {
			var nombre
			var edad
			
			constructor(n, m, e) {
				nombre = n
				edad = e
			}
		}
		'''.expectsSyntaxError("You should not mix named parameters with values in constructor calls", false)
	}

}