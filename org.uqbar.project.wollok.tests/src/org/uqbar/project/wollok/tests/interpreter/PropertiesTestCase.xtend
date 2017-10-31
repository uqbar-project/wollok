package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class PropertiesTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void getterAndSetterForPropertyVarInClass() {
		'''
		class Ave {
			var property energia = 100
			
			method volar() {
				energia -= 10
			}
		}
		
		test "energia inicial de pepita" {
			const pepita = new Ave()
			assert.equals(100, pepita.energia())
		}
		
		test "energia seteada de pepita" {
			const pepita = new Ave()
			pepita.energia(40)
			pepita.volar()
			assert.equals(30, pepita.energia())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void getterForPropertyConstInClass() {
		'''
		class Ave {
			const property fechaNacimiento = new Date()
			var property vecesQueVolo
			
			constructor() {
				vecesQueVolo = 0
			}
			
			method volar() {
				vecesQueVolo++
			}
		}
		
		test "fecha de nacimiento de pepita" {
			const pepita = new Ave()
			assert.equals(new Date(), pepita.fechaNacimiento())
		}
		
		test "al volar sigue constante la fecha de nacimiento de pepita" {
			const pepita = new Ave()
			pepita.volar()
			assert.equals(1, pepita.vecesQueVolo())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void getterForPropertyConstInWko() {
		'''
		object pepita {
			const property energia = 100
			const property numerosFavoritos = [1, 3, 5, 8]
			var property vecesQueVolo = self.energia() - 100
			
			method volar() {
				vecesQueVolo++
			}
		}
		
		test "energia inicial de pepita" {
			assert.equals(100, pepita.energia())
		}
		
		test "al volar sigue constante la energia de pepita" {
			pepita.volar()
			assert.equals(100, pepita.energia())
			assert.equals(1, pepita.vecesQueVolo())
			assert.equals([1, 3, 5, 8], pepita.numerosFavoritos())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void getterAndSetterForPropertyVarInWko() {
		'''
		object pepita {
			var property energia = 100
			
			method volar() {
				energia -= 10
			}
		}
		
		test "energia inicial de pepita" {
			assert.equals(100, pepita.energia())
		}
		
		test "energia seteada de pepita" {
			pepita.energia(40)
			pepita.volar()
			assert.equals(30, pepita.energia())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void getterAndSetterForPropertyVarInDescribe() {
		'''
		describe "grupo de tests" {
			var property valorInicial = 5
			var property valor = self.valorInicial()
			
			test "el valor es 5" {
				assert.equals(5, self.valor())
			}

			test "el valor es 2 cuando se lo digo" {
				self.valor(2)
				assert.equals(2, self.valor())
			}

		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void getterForPropertyConstInDescribe() {
		'''
		describe "grupo de tests" {
			const property valor
			
			fixture {
				valor = 5
			}
			
			test "el valor es 5" {
				assert.equals(5, self.valor())
			}
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void setterForPropertyConstInObject() {
		'''
		object pepita {
			const property energia = 0
		}
		program prueba {
			try {
				pepita.energia(10)
			} catch e : Exception {
				assert.equals("Cannot modify constant property energia", e.getMessage())
			}
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}

	@Test
	def void badSetterForPropertyConstInObject() {
		'''
		object pepita {
			const property energia = 0
		}
		program prueba {
			try {
				pepita.energia(10, "hola")
			} catch e : Exception {
				assert.equals("pepita[energia=0] does not understand energia(param1, param2)", e.getMessage())
			}
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}

	@Test
	def void setterForPropertyConstInClass() {
		'''
		class Ave {
			const property energia = 0
		}
		program prueba {
			const pepita = new Ave()
			try {
				pepita.energia(10)
			} catch e : Exception {
				assert.equals("Cannot modify constant property energia", e.getMessage())
			}
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}
	
	@Test
	def void badSetterForPropertyConstInClass() {
		'''
		class Ave {
			const property energia = 0
		}
		program prueba {
			const pepita = new Ave()
			try {
				pepita.energia(10, [21, 1])
			} catch e : Exception {
				assert.equals("a Ave[energia=0] does not understand energia(param1, param2)", e.getMessage())
			}
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}

}