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
				
				assert.equals('a Perro', perro.toString())
				assert.equals('casa', casa.toString())
				
				const anonymousObject = object {
					var edad = 23
					var altura = 2
				}
				
				assert.equals("an Object", anonymousObject.toString())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void toStringWithDoubleField() {
		'''
			object persona {
				var edad = 23
				var altura = 1.7
			}
			
			program p {
				assert.equals("persona", persona.toString())
			}
		'''.interpretPropagatingErrors
	}

}