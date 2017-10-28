package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class PropertiesTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void getterAndSetterForPropertyVarInClass() {
		'''
		class Ave {
			property var energia = 100
			
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
			property const energia = 100
			property var vecesQueVolo
			
			constructor() {
				vecesQueVolo = self.energia() - 100
			}
			
			method volar() {
				vecesQueVolo++
			}
		}
		
		test "energia inicial de pepita" {
			const pepita = new Ave()
			assert.equals(100, pepita.energia())
		}
		
		test "al volar sigue constante la energia de pepita" {
			const pepita = new Ave()
			pepita.volar()
			assert.equals(100, pepita.energia())
			assert.equals(1, pepita.vecesQueVolo())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void getterForPropertyConstInWko() {
		'''
		object pepita {
			property const energia = 100
			property var vecesQueVolo = self.energia() - 100
			
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
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void getterAndSetterForPropertyVarInWko() {
		'''
		object pepita {
			property var energia = 100
			
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
			property var valorInicial = 5
			property var valor = self.valorInicial()
			
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
			property const valor
			
			fixture {
				valor = 5
			}
			
			test "el valor es 5" {
				assert.equals(5, self.valor())
			}

		}
		'''.interpretPropagatingErrors
	}

}