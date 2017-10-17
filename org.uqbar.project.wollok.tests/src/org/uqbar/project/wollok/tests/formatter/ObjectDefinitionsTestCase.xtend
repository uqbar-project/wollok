package org.uqbar.project.wollok.tests.formatter

import org.junit.Test

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
method comer(gr){energia=energia+gr}}''', '''
		class Golondrina {
			const energia = 10
			const kmRecorridos = 0
			method comer(gr) {
				energia = energia + gr
			}
		}
		''')
	}

}
