package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
class ObjectDefinitionsTestCase extends AbstractWollokFormatterTestCase {

	@Test
	def void testBasicObjectDefinition() {
		assertFormatting(
			'''
          object        pepita     { var energia = 0  method volar() { energia    +=
10 }          
		''',
			'''
			object pepita {

				var energia = 0
			
				method volar() {
					energia += 10
				}
			
			}
			
			'''
		)
	}

	@Test
	def void testBasicUnnamedObjectDefinition() {
		assertFormatting(
		'''
        program prueba {    
        	
const pepita = object      {var energia             =
0
		method volar() {energia++ }
	}        	
 }          
		''',
		'''
		program prueba {
			const pepita = object {
				var energia = 0
				method volar() {
					energia++
				}
			}
		}
		'''
		)
	}
	
	@Test
	def void testUnnamedObjectDefinitionInAnExpression() {
		assertFormatting(
		'''
        program prueba {    

assert.equals(

object { var energia
= 0},                        object { var energia = 0       }
)        	
 }          
		''',
		'''
		program prueba {
			assert.equals(object {
				var energia = 0
			}, object {
				var energia = 0
			})
		}
		'''
		)
	}

	@Test
	def void testInheritingObjectDefinition() {
		assertFormatting(
			'''
          object        pepita  
          
          
          
inherits                    
 Ave


              { var energia = 0  method volar() { energia    +=
10 }          
		''',
			'''
			object pepita inherits Ave {

				var energia = 0
			
				method volar() {
					energia += 10
				}
			
			}
			
			'''
		)
	}

	@Test
	def void classFormatting_oneLineBetweenVarsAndMethods() throws Exception {
		assertFormatting('''class Golondrina { 
    		const energia = 10 
    		const kmRecorridos = 0
method comer(gr){energia=energia+gr} method jugar(){     return true      }}''', '''
		class Golondrina {

			const energia = 10
			const kmRecorridos = 0
		
			method comer(gr) {
				energia = energia + gr
			}
		
			method jugar() {
				return true
			}
		
		}
		
		''')
	}

	@Test
	def void testObjectDefinitionWithOneVariableOnly() {
		assertFormatting(
			'''
          object        pepita  
          
          
          

              var        
              
              z   
		''',
			'''
			object pepita {
			
				var z
			
			}
			
			'''
		)
	}

	@Test
	def void testObjectDefinitionWithOneMethodOnly() {
		assertFormatting(
			'''
          object        pepita  
          
          
          

              { method volar() { return 2 }          
		''',
			'''
			object pepita {
			
				method volar() {
					return 2
				}
			
			}
			
			'''
		)
	}

	@Test
	def void testClassDefinitionWithOneMethodOnly() {
		assertFormatting(
			'''
          class                 Ave  
          
          
          

              { method volar() { return 2 }          
		''',
			'''
			class Ave {
			
				method volar() {
					return 2
				}
			
			}
			
			'''
		)
	}

	@Test
	def void testClassDefinitionWithOneVariableOnly() {
		assertFormatting(
			'''
          class                 Ave{  
          
          
          

              var energia}
		''',
			'''
			class Ave {
			
				var energia
			
			}
			
			'''
		)
	}

	@Test
	def void testInheritingObjectDefinitionWithDefinitionItself() {
		assertFormatting(
			'''
			class Ave{method volar() {}
				
			}
          object        pepita  
          
          
          
inherits                    
 Ave


              { var energia = 0  
              
              
              override            method volar() { energia    +=
10 }          
		''',
			'''
			class Ave {
			
				method volar() {
				}
			
			}
			
			object pepita inherits Ave {

				var energia = 0
			
				override method volar() {
					energia += 10
				}
			
			}
			
			'''
		)
	}

	@Test
	def void testInheritingObjectDefinitionWithDefinitionItselfAfter() {
		assertFormatting(
			'''
          object        pepita  
          
          
          
inherits                    
 Ave


              { var energia = 0  
              
              
              override            method volar() { energia    +=
10 }          


			class Ave{method volar() {}
				
			}

		''',
			'''
			object pepita inherits Ave {

				var energia = 0
			
				override method volar() {
					energia += 10
				}
			
			}
			
			class Ave {
			
				method volar() {
				}
			
			}

			'''
		)
	}

	@Test
	def void testClassDefinitionWithConstructorOnly() {
		assertFormatting(
			'''
          class          Ave {  
          
          
          

              constructor(param1) {}}   
		''',
			'''
			class Ave {
			
				constructor(param1) {
				}
			
			}
			
			'''
		)
	}
	
	@Test
	def void testClassDefinitionWithConstructorAndVar() {
		assertFormatting(
			'''
          class          Ave {  
          
          
          var energia

              constructor(param1) {energia             = 0 }}   
		''',
			'''
			class Ave {
			
				var energia
			
				constructor(param1) {
					energia = 0
				}
			
			}
			
			'''
		)
	}

	@Test
	def void testBasicMixinDefinition() {
		assertFormatting(
			'''
          
          
             
             mixin           Volador {  
          
          
          var energia

              method volar(lugar) {energia             = 0 }}   
		''',
			'''
			mixin Volador {
			
				var energia
			
				method volar(lugar) {
					energia = 0
				}
			
			}
			
			'''
		)
	}

	@Test
	def void testBasicMixinUse() {
		assertFormatting(
			'''
          
          
             
             mixin           Volador {  
          
          
          var energia

              method volar(lugar) {energia             = 0 }} class Ave 
              
              mixed with  
              
               Volador {
              	
              	method                 comer() { energia = 100
              	}
              }   
		''',
			'''
			mixin Volador {
			
				var energia
			
				method volar(lugar) {
					energia = 0
				}
			
			}
			
			class Ave mixed with Volador {

				method comer() {
					energia = 100
				}
			
			}
			
			'''
		)
	}

	@Test
	def void testVariableInitializedBeforeConstructor() {
		assertFormatting(
		'''
		class Ave {
			var amigas = new Set()
			constructor() {}
		}
		''',
		'''
		class Ave {
		
			var amigas = new Set()
		
			constructor() {
			}

		}
		
		'''
		)
	}
			
	@Test
	def testObjectInheritingParentWithParameterizedConstructor() {
		assertFormatting('''
object luisAlberto inherits Musico (
	
	8
) {

	var guitarra
}		
		''',
		'''
		object luisAlberto inherits Musico (8) {

			var guitarra
		
		}
		
		''')
	}

	@Test
	def testObjectInheritingParentWithParameterizedConstructor2() {
		assertFormatting('''
object luisAlberto inherits Musico (
	
	8
	
	, "estrelicia"
) {

	var guitarra
}		
		''',
		'''
		object luisAlberto inherits Musico (8, "estrelicia") {

			var guitarra
		
		}
		
		''')
	}

	@Test
	def testClassDefinition() {
		assertFormatting(
		'''
         




class Cancion {
	
	
	}		
		''',
		'''
		class Cancion {
		
		}
		
		'''
		)
	}
	
	@Test
	def void objectDefinition() {
		assertFormatting(
			'''
object luisAlberto inherits Musico {

	var guitarra = null

	method cambiarGuitarra(_guitarra) {
		guitarra = _guitarra
	}

	override method habilidad() = return 100.min(8 * guitarra.unidadesDeGuitarra())
	override method remuneracion(presentacion) = if (presentacion.participo(self)) self.costoPresentacion(presentacion) else 0

	method costoPresentacion(presentacion) = if (presentacion.fecha() < new Date(01, 09, 2017)) {
		return 1000
	} else {
		return 1200
	}

	override method interpretaBien(cancion) = true

}
			
			''',
			'''
			object luisAlberto inherits Musico {
			
				var guitarra = null
			
				method cambiarGuitarra(_guitarra) {
					guitarra = _guitarra
				}
			
				override method habilidad() = return 100.min(8 * guitarra.unidadesDeGuitarra())

				override method remuneracion(presentacion) = if (presentacion.participo(self)) self.costoPresentacion(presentacion) else 0
			
				method costoPresentacion(presentacion) = if (presentacion.fecha() < new Date(01, 09, 2017)) {
					return 1000
				} else {
					return 1200
				}
			
				override method interpretaBien(cancion) = true
			
			}

			'''
		)
	}
	
	@Test
	def void testPresentacion() {
		assertFormatting(
			'''
class Presentacion {

	const fecha
	const locacion
	var participantes = []

	constructor(_fecha, _locacion) {
		fecha = _fecha
		locacion = _locacion
	}

	method fecha() = fecha

	method locacion() = locacion

	method participantes() = participantes

	method participo(musico) = participantes.contains(musico)

	method capacidad() = self.locacion().capacidadPorDia(fecha)

	method agregarParticipantes(persona) {
		if (participantes.contains(persona)) {
			self.error("La persona que se desea agregar ya pertence a la presentaci�n")
		} else {
			participantes.add(persona)
		}
	}

	method quitarParticipante(persona) {
		if (not        (participantes.isEmpty())) {
			if (participantes.contains(persona)) {
				participantes.remove(persona)
			} else {
				self.error("La persona que se desea quitar no era integrante de la presentaci�n")
			}
		} else {
			self.error("El conjunto de participantes esta vacio")
		}
	}

	method costoPresentacion() {
		var costo = 0
		self.participantes().forEach{ participante => costo += participante.remuneracion(self) }
		return costo
	}

}
			
			''',
			'''
			class Presentacion {
			
				const fecha
				const locacion
				var participantes = []
			
				constructor(_fecha, _locacion) {
					fecha = _fecha
					locacion = _locacion
				}
			
				method fecha() = fecha
			
				method locacion() = locacion
			
				method participantes() = participantes
			
				method participo(musico) = participantes.contains(musico)
			
				method capacidad() = self.locacion().capacidadPorDia(fecha)
			
				method agregarParticipantes(persona) {
					if (participantes.contains(persona)) {
						self.error("La persona que se desea agregar ya pertence a la presentaci�n")
					} else {
						participantes.add(persona)
					}
				}
			
				method quitarParticipante(persona) {
					if (not (participantes.isEmpty())) {
						if (participantes.contains(persona)) {
							participantes.remove(persona)
						} else {
							self.error("La persona que se desea quitar no era integrante de la presentaci�n")
						}
					} else {
						self.error("El conjunto de participantes esta vacio")
					}
				}
			
				method costoPresentacion() {
					var costo = 0
					self.participantes().forEach({ participante => costo += participante.remuneracion(self) })
					return costo
				}
			
			}
			
			'''
		)
	}
	
}
