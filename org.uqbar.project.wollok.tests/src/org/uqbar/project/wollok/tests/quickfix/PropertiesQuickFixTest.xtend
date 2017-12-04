package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

/**
 * author dodain
 */
class PropertiesQuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def testRemovePropertyInMethodLocalVariableClass(){
		val initial = #['''
			class MyClass{
				method someMethod(){ 
					var property hello = "hola"
				}
			}
		''']

		val result = #['''
			class MyClass{
				method someMethod(){ 
					var hello = "hola"
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_property_definition_name)
	}

	@Test
	def testRemovePropertyInMethodLocalVariableWko(){
		val initial = #['''
			object pepita {
				method someMethod() {
					var property hello = "hola"
				}
			}
		''']

		val result = #['''
			object pepita {
				method someMethod() {
					var hello = "hola"
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_property_definition_name)
	}

	@Test
	def testRemovePropertyInTestLocalVariable(){
		val initial = #['''
			test "a special test" {
				var property x = 1
				assert.equals(1, x)
			}
		''']

		val result = #['''
			test "a special test" {
				var x = 1
				assert.equals(1, x)
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_property_definition_name)
	}

	@Test
	def testRemovePropertyInConstructorLocalVariable(){
		val initial = #['''
			class Ave {
				var alas
				constructor() {
					var property hello = "hola"
					alas = hello.size()
				}
			}
		''']

		val result = #['''
			class Ave {
				var alas
				constructor() {
					var hello = "hola"
					alas = hello.size()
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_property_definition_name)
	}

	@Test
	def testCreatePropertyOnWKO1(){
		val initial = #['''
			object pepita {
				method volar() { 
				}
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']

		val result = #['''
			object pepita {
				const property energia = initialValue
			
				method volar() { 
				}
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_createProperty_name)
	}

	@Test
	def testCreatePropertyOnWKO2(){
		val initial = #['''
			object pepita {}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']

		val result = #['''
			object pepita {
				const property energia = initialValue
			
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_createProperty_name)
	}
	
	@Test
	def testCreatePropertyOnWKO3(){
		val initial = #['''
			object pepita {
				var color = "azul"
			
			
				method volar() {
					color = "rojo"
				}
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']

		val result = #['''
			object pepita {
				var color = "azul"
			
			
				const property energia = initialValue
			
				method volar() {
					color = "rojo"
				}
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_createProperty_name)
	}

	@Test
	def testCreatePropertyOnWKO4(){
		val initial = #['''
			object pepita {
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']

		val result = #['''
			object pepita {
			
				const property energia = initialValue
			
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_createProperty_name)
	}

	@Test
	def testAddPropertyToSelfInWko(){
		val initial = #['''
			object pepita {
				var energia = 0
				
				method valentia() {
					energia++
					self.energia()
				}
			}
		''']

		val result = #['''
			object pepita {
				var property energia = 0
				
				method valentia() {
					energia++
					self.energia()
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_createProperty_name)
	}

	@Test
	def testAddPropertyVarToWko(){
		val initial = #['''
			object pepita {
				var energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']

		val result = #['''
			object pepita {
				var property energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_createProperty_name)
	}

	@Test
	def testAddPropertyConstToWko(){
		val initial = #['''
			object pepita {
				const energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']

		val result = #['''
			object pepita {
				const property energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					assert.equals(0, pepita.energia())
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_createProperty_name)
	}

	@Test
	def testAddPropertyWritableToWko(){
		val initial = #['''
			object pepita {
				const energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					pepita.energia(11)
				}
			}
		''']

		val result = #['''
			object pepita {
				var property energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					pepita.energia(11)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_convertPropertyVar_name)
	}

	@Test
	def testAddPropertyWritableToWko2(){
		val initial = #['''
			object pepita {
				var energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					pepita.energia(11)
				}
			}
		''']

		val result = #['''
			object pepita {
				var property energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					pepita.energia(11)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_convertPropertyVar_name)
	}

	@Test
	def testAddPropertyWritableToWko3(){
		val initial = #['''
			object pepita {
				const property energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					pepita.energia(11)
				}
			}
		''']

		val result = #['''
			object pepita {
				var property energia = 0
				
				method valentia() = energia
			}
			
			object entrenador {
				method primerDia() {
					pepita.energia(11)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_convertPropertyVar_name)
	}

	@Test
	def testAddPropertyWritableToSelf1(){
		val initial = #['''
			object pepita {
				const energia = 0
				
				method valentia() = energia
				method volar() {
					self.energia(100)
				}
			}
		''']

		val result = #['''
			object pepita {
				var property energia = 0
				
				method valentia() = energia
				method volar() {
					self.energia(100)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_convertPropertyVar_name)
	}

	@Test
	def testAddPropertyWritableToSelf2(){
		val initial = #['''
			object pepita {
				var energia = 0
				
				method valentia() = energia
				method volar() {
					self.energia(100)
				}
			}
		''']

		val result = #['''
			object pepita {
				var property energia = 0
				
				method valentia() = energia
				method volar() {
					self.energia(100)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_convertPropertyVar_name)
	}

	@Test
	def testAddPropertyWritableToSelf3(){
		val initial = #['''
			object pepita {
				const property energia = 0
				
				method valentia() = energia
				method volar() {
					self.energia(100)
				}
			}
		''']

		val result = #['''
			object pepita {
				var property energia = 0
				
				method valentia() = energia
				method volar() {
					self.energia(100)
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_convertPropertyVar_name)
	}
	
}