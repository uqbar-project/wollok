package org.uqbar.project.wollok.tests.parser

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.api.Test

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
		'''.expectsValidationError("You should not mix named and positional parameters", false)
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
		'''.expectsValidationError("You should not mix named and positional parameters", false)
	}

	/**
	 * From now on these tests are not syntax errors, but validation ones
	 * since Wollok Parser can't distinguish between initializers and values 
	 * when they both appear, so it is mapped as a list of positional parameters  
	 */
	@Test
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
		'''.expectsValidationError("You should not mix named and positional parameters", false)
	}

	@Test
	def void mixingNamedAndPositionalParametersInWKO2() {
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

		object firulais inherits Perro(22, nombre = "Firu") {
			method ladrar() = "Guau"
		}
		'''.expectsValidationError("You should not mix named and positional parameters", false)
	}

	@Test
	def void mixingNamedAndPositionalParametersInObjectLiteral1() {
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
		program prueba {
			const firulais = object inherits Perro(nombre = "Firu", 22) {
				method ladrar() = "Guau"
			}
		}
		'''.expectsValidationError("You should not mix named and positional parameters", false)
	}

	@Test
	def void mixingNamedAndPositionalParametersInObjectLiteral2() {
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
		program prueba {
			const firulais = object inherits Perro(22, nombre = "Firu") {
				method ladrar() = "Guau"
			}
		}
		'''.expectsValidationError("You should not mix named and positional parameters", false)
	}

	@Test
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
		'''.expectsValidationError("Named parameters are not allowed here", false)
	}

	@Test
	def void mixingPositionAndNamedParametersForSuperDelegatingConstructor2() {
		'''
		class Animal {
			var edad
		
			constructor(e, e0, e1) {
				edad = e
			}
		}
		
		class Perro inherits Animal {
			var nombre
		
			constructor(n, e) = super(edad = e, 1, 22) {
				nombre = n
			}
		
			method nombre() = nombre
		}
		'''.expectsValidationError("Named parameters are not allowed here", false)
	}

	@Test
	def void mixingPositionAndNamedParametersForSelfDelegatingConstructor1() {
		'''
		class Animal {
			var edad
		
			constructor(e, e0, e1) {
				edad = e
			}
		}
		
		class Perro inherits Animal {
			var nombre
			var otraVariable
		
			constructor(n) = self(otraVariable = 2, 1) {
			}
			
			constructor(n, e) {
				nombre = n
			}
		
			method nombre() = nombre
		}
		'''.expectsValidationError("Named parameters are not allowed here", false)
	}

	@Test
	def void mixingPositionAndNamedParametersForSelfDelegatingConstructor2() {
		'''
		class Animal {
			var edad
		
			constructor(e, e0, e1) {
				edad = e
			}
		}
		
		class Perro inherits Animal {
			var nombre
			var otraVariable
		
			constructor(n) = self(1, otraVariable = 2) {
			}
			
			constructor(n, e) {
				nombre = n
			}
		
			method nombre() = nombre
		}
		'''.expectsValidationError("Named parameters are not allowed here", false)
	}
	
}