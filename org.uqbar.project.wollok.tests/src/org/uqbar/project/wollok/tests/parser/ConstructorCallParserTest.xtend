package org.uqbar.project.wollok.tests.parser

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/** 
 * Test representative error messages for constructors calls
 * @author dodain
 */
class ConstructorCallParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void mixingNamedAndPositionalParameters() {
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
		'''.expectsValidationError("You should not mix named parameters with values in constructor calls", false)
	}

	@Test
	def void mixingNamedAndPositionalParameters2() {
		'''
		object wollok {
			method perro() {
				return new Perro(23, 30, nombre = "firulais", edad = 12, 23)
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
		'''.expectsValidationError("You should not mix named parameters with values in constructor calls", false)
	}

}