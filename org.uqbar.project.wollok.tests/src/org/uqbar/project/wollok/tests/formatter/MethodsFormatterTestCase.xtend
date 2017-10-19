package org.uqbar.project.wollok.tests.formatter

import org.junit.Test

class MethodsFormatterTestCase extends AbstractWollokFormatterTestCase {

	@Test
	def void testBasicFormattingInMethod() {
		assertFormatting(
		'''
		object        foo     {
		method bar(     param  ,  param2      ) {
		console.println("")
		console.println("")
		}
		}
		''',
		'''
		object foo {
		
			method bar(param, param2) {
				console.println("")
				console.println("")
			}
		
		}
		
		'''
		)
	}

	@Test
	def void testBasicFormattingSeveralMethods() {
		assertFormatting(
		'''
		             object        foo     {
		method bar(     param  ,  param2      ) {
		console.println("")
		console.println("")
		}method bar2() { return 3 }
		

method bar3() { assert.that(true)		var a = 1 + 1 console.println(a)}		
		}
		''',
		'''
		object foo {
		
			method bar(param, param2) {
				console.println("")
				console.println("")
			}
		
			method bar2() {
				return 3
			}
		
			method bar3() {
				assert.that(true)
				var a = 1 + 1
				console.println(a)
			}
		
		}
		
		'''
		)
	}

	@Test
	def void testReturnMethod() {
		assertFormatting(
		'''
		object        foo     {
		method bar(     param  ,  param2      )     
		= 2 
		
					method      bar2()          =                                self.bar(1, "hola")
		}
		''',
		'''
		object foo {
		
			method bar(param, param2) = 2
		
			method bar2() = self.bar(1, "hola")
		
		}
		
		'''
		)
	}

	@Test
	def void testOverrideMethod() {
		assertFormatting(
		'''
		class Parent        {
		method bar(     param  ,  param2      )     
		= 2 
		
					method      bar2()     {  
						
						return self.bar(1, "hola")
						}
		} class Child                     
inherits       Parent{ var a = 0
							override method bar(param, param2) = super()
							
							+ 10
							override method bar2() { a++           }   
		}
		''',
		'''
		class Parent {
		
			method bar(param, param2) = 2
		
			method bar2() {
				return self.bar(1, "hola")
			}
		
		}
		
		class Child inherits Parent {
		
			var a = 0
		
			override method bar(param, param2) = ( super() + 10 )
		
			override method bar2() {
				a++
			}
		
		}
		
		'''
		)
	}
	
	@Test
	def void testNativeMethod() {
		assertFormatting(
		'''
		object        foo     {
		method bar(     param  ,  param2      )           native
		method bar2()
		
		
		native
		
		}
		''',
		'''
		object foo {
		
			method bar(param, param2) native
		
			method bar2() native
		
		}
		
		'''
		)
	}
	
	@Test
	def void abstractMethods() {
		assertFormatting(
		'''
		class Vehicle {
		    method numberOfPassengers()   method maxSpeed() 
		    method expenseFor100Km() 
		    method efficiency() {
		        return        self.numberOfPassengers()      *     self.maxSpeed()     /       
		        
		        
		        self.expenseFor100Km()
		    } 
		}
		''',
		'''
		class Vehicle {
		
			method numberOfPassengers()
		
			method maxSpeed()
		
			method expenseFor100Km()
		
			method efficiency() {
				return ( self.numberOfPassengers() * self.maxSpeed() ) / self.expenseFor100Km()
			}
		
		}
		
		'''
		)
	}

	@Test
	def void testClassFormattingOneLineMethod() throws Exception {
		assertFormatting('''class    Golondrina {    const    energia      =      10 
		
		
const                  kmRecorridos= 0 method comer(gr) { energia = energia + gr } }''', '''
		class Golondrina {
		
			const energia = 10
			const kmRecorridos = 0
		
			method comer(gr) {
				energia = energia + gr
			}
		
		}
		
		''')
	}

	@Test
	def void testClassFormattingOneLineMethodStaysInNewLine() throws Exception {
		assertFormatting('''class Golondrina { const energia = 10 const kmRecorridos = 0 method comer(gr) { 
    		energia = energia + gr
    	} }''', '''
		class Golondrina {
		
			const energia = 10
			const kmRecorridos = 0
		
			method comer(gr) {
				energia = energia + gr
			}
		
		}
		
		''')
	}

	@Test
	def void keepNewlinesInSequences() throws Exception {
		assertFormatting(
    	'''
		object foo {
			method bar() {
				self.bar().bar().bar()
				
				console.println("") console.println("")
				
				console.println("") 
				console.println("")
			}
		}''', '''
		object foo {
		
			method bar() {
				self.bar().bar().bar()
				console.println("")
				console.println("")
				console.println("")
				console.println("")
			}
		
		}
		
		''')
	}

	@Test
	def void messageSendParameters() throws Exception {
		assertFormatting('''program p { 
    		const a = null
    		
    		a . doSomething  ( a, a,    a , a ,  a   )
    		a ?. doSomething  ( a, a,    a , a ,  a   )
    		a ?. doSomething  ({=> a .doSomething()})
    	}''', '''
		program p {
			const a = null
			a.doSomething(a, a, a, a, a)
			a?.doSomething(a, a, a, a, a)
			a?.doSomething({
				=>
					a.doSomething()
			})
		}
		''')
	}


	@Test
	def void listWithPreviousConflicts() throws Exception {
		assertFormatting(
		'''
  class Presentacion {
	var fecha
	var musicos
	var lugar
	constructor() {
		musicos = []
	}
	method fecha(_fecha) {
		fecha = _fecha
	}
	method lugar(_lugar) {
		lugar = _lugar
	}
	method agregarMusico(musico) {
		musicos.add(musico)
	}
	method eliminarMusicos() {
		musicos.clear()
	}
	method fecha() = fecha

	method lugarConcurrido() = lugar.capacidad(fecha) > 5000
	method tocaSolo(musico) = [ musico ] == musicos
	method costo() = musicos.sum{
		musico =>
			musico.precioPorPresentacion(self)
	}
}		
		''',
		'''
		class Presentacion {
		
			var fecha
			var musicos
			var lugar
		
			constructor() {
				musicos = []
			}
		
			method fecha(_fecha) {
				fecha = _fecha
			}
		
			method lugar(_lugar) {
				lugar = _lugar
			}
		
			method agregarMusico(musico) {
				musicos.add(musico)
			}
		
			method eliminarMusicos() {
				musicos.clear()
			}
		
			method fecha() = fecha
		
			method lugarConcurrido() = ( lugar.capacidad(fecha) > 5000 )
		
			method tocaSolo(musico) = ( [ musico ] == musicos )
		
			method costo() = musicos.sum({
				musico =>
					musico.precioPorPresentacion(self)
			})
		
		}
		
		''')
	}

	@Test
	def void testSuperInvocation() throws Exception {
		assertFormatting('''class   Ave { 
			
			
			var energia = 0
			method volar(minutos) { energia -= minutos}}
			class Golondrina {
				
				override method volar(minutos) {  super
				
				(minutos * ( 10 - 2 ) ) }        
 }''', '''
		class Ave {
		
			var energia = 0
		
			method volar(minutos) {
				energia -= minutos
			}
		
		}
		
		class Golondrina {
		
			override method volar(minutos) {
				super(minutos * ( 10 - 2 ))
			}
		
		}
		
		''')
	}

}