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
			
	
}
