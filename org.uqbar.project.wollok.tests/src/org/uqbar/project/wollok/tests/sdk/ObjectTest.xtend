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
			
			program p {
				val perro = new Perro()
				
				assert.equals("anObject[edad=7, nombre=Colita]", perro.toString())
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
				
				assert.equals("#[edad=7, nombre=Colita]",instVars.toString())
			}
		'''.interpretPropagatingErrors
	}
	
}