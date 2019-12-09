package org.uqbar.project.wollok.tests.quickfix

import org.junit.jupiter.api.Test
import org.uqbar.project.wollok.ui.Messages

class OverridingQuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def removeUnnecesaryOverridenMethod(){
		val initial = #['''
			class Pirata {
				var bravura = 70
				
				method subir(barco) {
					bravura += 10
				}
			}
			
			class PirataEspecial inherits Pirata {
				const misiones = []
				
				method cantidadMisiones() = misiones.size()
				
				override method subir(barco) {
					super(barco)
				}
			}
		''']

		val result = #['''
			class Pirata {
				var bravura = 70
				
				method subir(barco) {
					bravura += 10
				}
			}
			
			class PirataEspecial inherits Pirata {
				const misiones = []
				
				method cantidadMisiones() = misiones.size()
				
				
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_method_name)
	}

	@Test
	def removeUnnecesaryOverridenMethod2(){
		val initial = #['''
			class Pirata {
				const bravura = 70
				
				method bravura() = bravura
			}
			
			class PirataEspecial inherits Pirata {
				const misiones = []
				
				method cantidadMisiones() = misiones.size()
				
				override method bravura() = super()
			}
		''']

		val result = #['''
			class Pirata {
				const bravura = 70
				
				method bravura() = bravura
			}
			
			class PirataEspecial inherits Pirata {
				const misiones = []
				
				method cantidadMisiones() = misiones.size()
				
				
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_method_name)
	}

}