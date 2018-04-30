package org.uqbar.project.wollok.tests.parser

import org.junit.Ignore
import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/** 
 * Test representative error messages for constructors calls
 * @author dodain
 */
class ConstructorCallParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void mixingNamedAndPositionalParametersInConstructorCall1() {
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
	def void mixingPositionAndNamedParametersInConstructorCall2() {
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

	// TODO: Ver si agregamos una validación
	@Test
	@Ignore
	def void mixingNamedAndPositionalParametersInWKO1() {
		'''
		class Perro {
			var nombre = ""
			var edad = 0
			constructor() {
			}
			constructor(_nombre, _edad) {
				nombre = _nombre
				edad = _edad
			}
		}

		object firulais inherits Perro(nombre = "Firu", 22) {
			method ladrar() = "Guau"
		}
		'''.expectsValidationError("You should not mix named parameters with values in constructor calls", false)
	}

	// TODO: Ver si agregamos una validación
	@Test
	@Ignore
	def void mixingPositionAndNamedParametersForSuperDelegatingConstructor() {
		'''
		class Animal {
			var edad
		
			constructor(e, e0, e1) {
				edad = e
			}
		}
		
		class Perro inherits Animal {
			var nombre
		
			constructor(n, e) = super(1, edad = e, 22) {
				nombre = n
			}
		
			method nombre() = nombre
		}
		'''.expectsValidationError("You should not mix named parameters with values in constructor calls", false)
	}
	
}