package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Tests Recursive to string
 * 
 * @author tesonep
 */
class RecursiveToStringTestCase extends AbstractWollokInterpreterTestCase {

	@Test
	def void testLists() {
		'''
			object obj2 {
				var y 
				method setY(anObject){
					y = anObject
				}
			}
			
			object obj1 {
				var x = []
				method addX(anObject){
					x.add(anObject)
				}
			}
			
			class Prb {
				
			}

			program a {
				obj1.addX(obj2)
				obj2.setY(obj1)
				obj1.addX(new Prb())
				
				assert.equals('obj2', obj2.toString())
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testNulls() {
		'''
			object obj1{
				var x
			}
			program a {
				console.println(obj1)
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testMessageErrorInBidirectionalRelationship() {
		'''
		class Cuenta {
			const property duenios = []
		}
		
		class Duenio {
			const property cuentas = []
		}
		
		program prueba {
			try {
				const cuenta = new Cuenta()
				const duenio = new Duenio(cuentas = [ cuenta ])
				cuenta.duenios().add(duenio)
				cuenta.metodoInexistente()
			} catch e {
				assert.equals("a Cuenta does not understand metodoInexistente()", e.message())
			}
		}
		'''.interpretPropagatingErrors
	}
}