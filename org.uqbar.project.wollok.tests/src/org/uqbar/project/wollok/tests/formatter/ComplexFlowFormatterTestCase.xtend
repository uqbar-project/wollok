package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
class ComplexFlowFormatterTestCase extends AbstractWollokFormatterTestCase {
	
	@Test
	def void program_ifInline() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    			   const c = if     (a > 0)    b                    else 
    			   
    			   
    			   0
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = if (a > 0) b else 0
		}
		''')
	}

	@Test
	def void program_ifInlineWithExpressions() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    		const c = if (a > 0) b+1 else b-1
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = if (a > 0) b + 1 else b - 1
		}
		''')
	}

	@Test
	def void issue702_forEachAndIf() throws Exception {
		assertFormatting('''
		object foo {
		    method bar() {
		        [3,              4        ,50,      100 ].forEach({ it => if (it > 4) { console.println(4) } else {console.println(it)
		            }
		        })
		    }
		}
		''',
		'''
		object foo {
		
			method bar() {
				[ 3, 4, 50, 100 ].forEach({ it =>
					if (it > 4) {
						console.println(4)
					} else {
						console.println(it)
					}
				})
			}
		
		}
		
		''')
	}

	@Test
	def void issue702_forEachAndIf_2() throws Exception {
		assertFormatting('''
		object foo {
		    method bar() {
		        [3,              4        ,50,      100 ].forEach({ it => if (it > 4) console.println(4) else console.println(it)
		           
		        })
		    }
		}
		''',
		'''
		object foo {
		
			method bar() {
				[ 3, 4, 50, 100 ].forEach({ it =>
					if (it > 4) console.println(4) else console.println(it)
				})
			}
		
		}
		
		''')
	}
	
	@Test
	def void program_maxOneLineBreakBetweenLines() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    		
    		
    		const c = a + b
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = a + b
		}
		''')
	}

	@Test
	def void basicTryCatch() {
		assertFormatting('''
program abc {
    console.println(4)
    try
        {
            5 + 5
        }
            catch e : Exception
            {
                console.println(e)
            }
        }		
		''',
		'''
		program abc {
			console.println(4)
			try {
				5 + 5
			} catch e : Exception {
				console.println(e)
			}
		}
        ''')
	}

	@Test
	def void tryBlockWithSeveralCatchsAndAFinally() {
		assertFormatting('''
program abc {
    console.println(4)
    try{5 + 5}
            catch e : UserException       {
                console.println(e)
            }              catch e2:Exception {console.println("Bad error")       console.println("Do nothing")} 
            
            
            
            
            
            then always { console.println("finally") 
            
            
            }
        }		
		''',
		'''
		program abc {
			console.println(4)
			try {
				5 + 5
			} catch e : UserException {
				console.println(e)
			} catch e2 : Exception {
				console.println("Bad error")
				console.println("Do nothing")
			} then always {
				console.println("finally")
			}
		}
        ''')
	}

	@Test
	def void oneLineTryCatch() {
		assertFormatting('''
program abc {
    console.println(4)
    try
    
    
    
    
            5 + 5
    
    
            catch e : Exception
    
    
                console.println(e)
        }		
		''',
		'''
		program abc {
			console.println(4)
			try
				5 + 5
			catch e : Exception
				console.println(e)
		}
        ''')
	}

	@Test
	def void throwFormattingTest() {
		assertFormatting(
		'''
		object foo {
method attack(target) {
                           var attackers = self.standingMembers()
             if (attackers.isEmpty()) throw
                                new CannotAttackException("No attackers available") attackers.forEach({
                                        aMember          =>   
                                        
                                        
                                        aMember.
                                        attack(target) })
}		
}
		''',
		'''
		object foo {
		
			method attack(target) {
				var attackers = self.standingMembers()
				if (attackers.isEmpty()) throw new CannotAttackException("No attackers available")
				attackers.forEach({ aMember => aMember.attack(target) })
			}
		
		}
		
		''')
	}
	
	@Test
	def void testAllWithClosure() {
		assertFormatting(
		'''
		class Cantante { const albumes = new Set()
method esMinimalista() = albumes.all{
				album =>
					album.sonTodasCancionesCortas()
			}
	}	
		''',
		'''
		class Cantante {
		
			const albumes = new Set()
		
			method esMinimalista() = albumes.all({ album => album.sonTodasCancionesCortas() })
		
		}
		
		''')
	}		

	@Test
	def void testForEachWithComplexClosure() {
		assertFormatting(
		'''
		class Cantante { const albumes = new Set()
method mejorarAlbumes() {
	 albumes.forEach{
				album =>
					album.agregarCancion(new Cancion())
					album.sumarCosto(100)
			}}
	}	
		''',
		'''
		class Cantante {
		
			const albumes = new Set()
		
			method mejorarAlbumes() {
				albumes.forEach({ album =>
					album.agregarCancion(new Cancion())
					album.sumarCosto(100)
				})
			}
		
		}
		
		''')
	}
	
	@Test
	def void doubleIfInMethod() {
		assertFormatting(
		'''
		object pepita {
			const posicion = game.at(2, 0)
			var energia = 50
			method energia() {
				return energia
			}
			method imagen() {
				if (energia < 150) return "pepita.png"
				if (energia < 300) return "pepita1.png"
				return "pepita2.png"
			}
			
			
			}
		''',
		'''
		object pepita {
		
			const posicion = game.at(2, 0)
			var energia = 50
		
			method energia() {
				return energia
			}
		
			method imagen() {
				if (energia < 150) return "pepita.png"
				if (energia < 300) return "pepita1.png"
				return "pepita2.png"
			}

		}
		
		''')
	}

	@Test
	def void testWithIfExpression() {
		assertFormatting(
		'''
		object laTrastienda {
		
			const capacidadPlantaBaja = 400
			const capacidadPrimerPiso = 300
		
			method capacidad(dia) {
				if (dia.dayOfWeek() 
				
				
				== 6) {
					return capacidadPlantaBaja + capacidadPrimerPiso
				} else {
					return capacidadPlantaBaja
				}
			}
		
		}
		''',
		'''
		object laTrastienda {
		
			const capacidadPlantaBaja = 400
			const capacidadPrimerPiso = 300
		
			method capacidad(dia) {
				if (dia.dayOfWeek() == 6) {
					return capacidadPlantaBaja + capacidadPrimerPiso
				} else {
					return capacidadPlantaBaja
				}
			}
		
		}
		
		''')
		
	}
	
	@Test
	def void testFold() {
		assertFormatting(
			'''
class Mashup inherits Cancion {

var nombre = ""
				 var   duracion = 0         
				var letra = ""
				  
				var bloqueNumeroPositivo =        {    num   =>          num > 0 }               
				
				
	constructor(canciones) {
		nombre = "MASHUP" + self.concatenarNombres(canciones)
		duracion = self.cancionMasLarga(canciones)
		letra = self.concatenarCanciones(canciones).trim()
	}



	method concatenarNombres(canciones) {
		return canciones.fold(""      ,       { acum , cancion => acum + cancion.nombre() } 
		
		
		)
	}

			}
			''',
			'''
			class Mashup inherits Cancion {

				var nombre = ""
				var duracion = 0
				var letra = ""
				var bloqueNumeroPositivo = { num => num > 0 }
			
				constructor(canciones) {
					nombre = "MASHUP" + self.concatenarNombres(canciones)
					duracion = self.cancionMasLarga(canciones)
					letra = self.concatenarCanciones(canciones).trim()
				}

				method concatenarNombres(canciones) {
					return canciones.fold("", { acum , cancion => acum + cancion.nombre() })
				}

			}
			
			'''
		)
	}

	@Test
	def testReturnAndIf() {
		assertFormatting(
			'''
object lucia {

	const costePresentacionNoConcurrida = 400
	const costePresentacionConcurrida = 500
	var cantaEnGrupo = true
	const habilidad = 70

	method habilidad() = habilidad + self.sumaHabilidad()

	method sumaHabilidad() {
		if (cantaEnGrupo) return   -  20
		return 0
	}
			}
			''',
			'''
			object lucia {
			
				const costePresentacionNoConcurrida = 400
				const costePresentacionConcurrida = 500
				var cantaEnGrupo = true
				const habilidad = 70
			
				method habilidad() = ( habilidad + self.sumaHabilidad() )
			
				method sumaHabilidad() {
					if (cantaEnGrupo) return -20
					return 0
				}

			}
			
			'''
		)
	}

	@Test
	def void testReturnSelfExpression() {
		assertFormatting(
		'''
class AlbumBuilder {

	var fechaLanzamiento

	method fechaLanzamiento(dia, mes, anio) {
		fechaLanzamiento = new Date(dia, mes, anio)
		return self
	}

}		''',
		'''
		class AlbumBuilder {
		
			var fechaLanzamiento
		
			method fechaLanzamiento(dia, mes, anio) {
				fechaLanzamiento = new Date(dia, mes, anio)
				return self
			}

		}

		''')
	}
	
	@Test
	def void unaryWordExpression() {
		assertFormatting('''
object pdpalooza inherits Presentacion(new Date(15, 12, 2017), lunaPark, []){
	const restriccionHabilidad = { musico => if (musico.habilidad() < 70) throw new Exception("La habilidad del músico debe ser mayor a 70")}
	const restriccionCompusoAlgunaCancion = {musico => if (not musico.compusoAlgunaCancion()) throw new Exception("El músico debe haber compuesto al menos una canción")}
}		
		''',
		'''
		object pdpalooza inherits Presentacion(new Date(15, 12, 2017), lunaPark, []) {
		
			const restriccionHabilidad = { musico =>
				if (musico.habilidad() < 70) throw new Exception("La habilidad del músico debe ser mayor a 70")
			}
			const restriccionCompusoAlgunaCancion = { musico =>
				if (not musico.compusoAlgunaCancion()) throw new Exception("El músico debe haber compuesto al menos una canción")
			}
		
		}
		
		''')
	}	
}