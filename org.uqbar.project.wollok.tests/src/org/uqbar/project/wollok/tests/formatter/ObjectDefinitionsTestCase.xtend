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
	def void testInheritingPositionalUnnamedObjectDefinition() {
		assertFormatting(
		'''
		class A { var _n = 0              }
        program prueba {    
        	
const pepita = object     inherits A(n= 



5


)
 {var energia             =
0
		method volar() {energia++ }
	}        	
 }          
		''',
		'''
		class A {
		
			var _n = 0
		
		}
		
		program prueba {
			const pepita = object inherits A(n = 5) {
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
	def void testInheritingNamedParametersUnnamedObjectDefinition() {
		assertFormatting(
		'''
		class A { var edad = 0 var nombre = ""}
        program prueba {    
        	
const pepita = object     inherits A( 



edad = 22


,


nombre


=       
"Carlono"
)
 {var energia             =
0
		method volar() {energia++ }
	}        	
 }          
		''',
		'''
		class A {
		
			var edad = 0
			var nombre = ""
		
		}
		
		program prueba {
			const pepita = object inherits A(edad = 22, nombre = "Carlono") {
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
	def void testInheritingPositionalParametersObjectDefinition() {
		assertFormatting(
			'''class Ave{}
          object        pepita  
          
          
          
inherits                    
 Ave


              { var energia = 0  method volar() { energia    = energia +
10 }          
		''',
			'''
			class Ave {
			
			}
			
			object pepita inherits Ave {

				var energia = 0
			
				method volar() {
					energia = energia + 10
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
          object        pepita  {
          
          
          

              var        
              
              z   }
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
	def void testClassDefinitionWithVar() {
		assertFormatting(
			'''
          class          Ave {  
          
          
          var energia

                                                                     }   
		''',
			'''
			class Ave {
			
				var energia
			
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
              
              inherits  
              
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
			
			class Ave inherits Volador {

				method comer() {
					energia = 100
				}
			
			}
			
			'''
		)
	}

	@Test
	def testObjectInheritingNamedParametersForWKO() {
		assertFormatting('''class Musico{var calidad}
object luisAlberto inherits Musico (calidad
	
	
	
= 
8
	
	, 
	
	
				cancionPreferida                      =
	"estrelicia"
) {

	var guitarra
}		
		''',
		'''
		class Musico {
		
			var calidad
		
		}
		
		object luisAlberto inherits Musico (calidad = 8, cancionPreferida = "estrelicia") {

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
					self.participantes().forEach({ participante => costo += participante.remuneracion(self)})
					return costo
				}
			
			}
			
			'''
		)
	}

	@Test
	def void testObjectVarsInitialized() {
		// EL PROBLEMA ESTA EN inherits Musico + if (presentacion.fecha() < fechaTope) valorFechaNoTope else valorFechaTope
		assertFormatting(
			'''
			class Musico{}
object luisAlberto inherits Musico {

	const valorFechaTope = 1200
	const valorFechaNoTope = 1000
	var guitarra = fender
	const fechaTope = new Date(day = 01, month = 09, year = 2017)

	override method habilidad() = (8 * guitarra.valor()).min(100)

	override method interpretaBien(cancion) = true

	method guitarra(_guitarra) {
		guitarra = _guitarra
	}

	method costo(presentacion) = if (presentacion.fecha() < fechaTope) valorFechaNoTope else valorFechaTope

}
			
			''',
			'''
			class Musico {
			
			}
			
			object luisAlberto inherits Musico {
			
				const valorFechaTope = 1200
				const valorFechaNoTope = 1000
				var guitarra = fender
				const fechaTope = new Date(day = 01, month = 09, year = 2017)
			
				override method habilidad() = (8 * guitarra.valor()).min(100)
			
				override method interpretaBien(cancion) = true
			
				method guitarra(_guitarra) {
					guitarra = _guitarra
				}
			
				method costo(presentacion) = if (presentacion.fecha() < fechaTope) valorFechaNoTope else valorFechaTope
			
			}

			'''
		)
	}	
}
