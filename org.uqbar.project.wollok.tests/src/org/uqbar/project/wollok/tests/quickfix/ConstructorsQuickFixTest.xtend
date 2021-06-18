package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class ConstructorsQuickFixTest extends AbstractWollokQuickFixTestCase {
	
	@Test
	def removeUnexistentAttributeInConstructorCall(){
		val initial = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energiaz = 100,   saludo = "Que onda?")
			}
		}
		''']

		val result = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(saludo = "Que onda?")
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_attribute_initialization_name)
	}

	@Test
	def removeUnexistentAttributeInConstructorCall2(){
		val initial = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 100, pavlov = 2, saludo = "Que onda?")
			}
		}
		''']

		val result = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 100, saludo = "Que onda?")
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_attribute_initialization_name)
	}

	@Test
	def removeUnexistentAttributeInConstructorCall3(){
		val initial = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(pavlov = 2, energia = 100, saludo = "Que onda?")
			}
		}
		''']

		val result = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 100, saludo = "Que onda?")
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_attribute_initialization_name)
	}
	
	@Test
	def removeUnexistentAttributeInConstructorCall4(){
		val initial = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(pavlov = 2)
			}
		}
		''']

		val result = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave()
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_attribute_initialization_name)
	}	

	@Test
	def removeUnexistentAttributeInConstructorCall5(){
		val initial = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 2,   pavlov = 2)
			}
		}
		''']

		val result = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 2)
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_attribute_initialization_name)
	}	

	@Test
	def removeUnexistentAttributeInConstructorCall6(){
		val initial = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 2,pavlov = 2)
			}
		}
		''']

		val result = #[
		'''
		class Ave {
			const energia = 1
			const saludo = "Hola"
			method energiaCalculada() = saludo.size() + energia
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 2)
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_attribute_initialization_name)
	}	

	@Test
	def addInitializationsInConstructorCall(){
		val initial = #[
		'''
		class Ave {
			var energia
			var saludo
			var color
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 2)
			}
		}
		''']

		val result = #[
		'''
		class Ave {
			var energia
			var saludo
			var color
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 2, saludo = value, color = value)
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_add_missing_initializations_name, 4, "You must provide initial value to the following references: color, saludo")
	}

	@Test
	def addInitializationsInConstructorCall2(){
		val initial = #[
		'''
		class Ave {
			var energia
			const saludo = 0
			var color
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 2)
			}
		}
		''']

		val result = #[
		'''
		class Ave {
			var energia
			const saludo = 0
			var color
		}
		object aveBuilder {
			method construirAve() {
				return new Ave(energia = 2, color = value)
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_add_missing_initializations_name, 4, "You must provide initial value to the following references: color")
	}
	
}