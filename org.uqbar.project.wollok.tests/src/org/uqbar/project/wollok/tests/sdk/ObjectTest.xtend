package org.uqbar.project.wollok.tests.sdk

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * Test for the wollok.lang.Object class
 * 
 * @author jfernandes
 */
class ObjectTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void defaultToString() {
		'''
			class Perro {
				var nombre = "Colita"
				var edad = 7
			}
			
			object casa {
				var ambientes = 3
				var direccion = "San Juan 1234"
			}
			
			program p {
				const perro = new Perro()
				
				assert.equals("a Perro[nombre=Colita, edad=7]", perro.toString())
				assert.equals("casa[direccion=San Juan 1234, ambientes=3]", casa.toString())
				
				const anonymousObject = object {
					var edad = 23
					var altura = 2
				}
				
				assert.equals("an Object[edad=23, altura=2]", anonymousObject.toString())
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void instanceVariableFor() {
		'''
			class Perro {
				var nombre = "Colita"
				var edad = 7
			}
			
			program p {
				const perro = new Perro()
				
				const instVar = perro.instanceVariableFor("nombre")
				
				assert.that(instVar != null)
				
				assert.equals("nombre", instVar.name())
				assert.equals("Colita", instVar.value())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void instanceVariables() {
		'''
			class Perro {
				var nombre = "Colita"
				var edad = 7
			}
			
			program p {
				const perro = new Perro()
				
				const instVars = perro.instanceVariables()
				assert.equals(2, instVars.size())
				
				const nombreInstVar = instVars.find{e=> e.name() == "nombre"}
				assert.equals("Colita", nombreInstVar.value())
				
				const edadInstVar = instVars.find{e=> e.name() == "edad"}
				assert.equals(7, edadInstVar.value())
				
«««				assert.equals("#[edad=7, nombre=Colita]",instVars.toString())
			}
		'''.interpretPropagatingErrors
	}
	
}