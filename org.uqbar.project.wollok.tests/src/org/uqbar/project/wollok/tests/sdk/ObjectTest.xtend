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
				val perro = new Perro()
				
				assert.equals("a Perro[edad=7, nombre=Colita]", perro.toString())
				assert.equals("casa[ambientes=3, direccion=San Juan 1234]", casa.toString())
				
				val anonymousObject = object {
					var edad = 23
					var altura = 1.7
				}
				
«««				//TODO
«««				assert.equals("anObject[edad=23, altura=1.7]", anonymousObject.toString())
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
				val perro = new Perro()
				
				val instVar = perro.instanceVariableFor("nombre")
				
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
				val perro = new Perro()
				
				val instVars = perro.instanceVariables()
				assert.equals(2, instVars.size())
				
				val nombreInstVar = instVars.detect[e| e.name() == "nombre"]
				assert.equals("Colita", nombreInstVar.value())
				
				val edadInstVar = instVars.detect[e| e.name() == "edad"]
				assert.equals(7, edadInstVar.value())
				
«««				assert.equals("#[edad=7, nombre=Colita]",instVars.toString())
			}
		'''.interpretPropagatingErrors
	}
	
}