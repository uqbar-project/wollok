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
				var x = #[]
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
				
				this.println(obj2)
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
				this.println(obj1)
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testSets() {
		'''
			object obj2 {
				var y 
				method setY(anObject){
					y = anObject
				}
			}
			
			object obj1 {
				var x = #{}
				method addX(anObject){
					x.add(anObject)
				}
			}
			
			class Prb{
				
			}

			program a {
				obj1.addX(obj2)
				obj2.setY(obj1)
				obj1.addX(new Prb())
				
				this.println(obj2)
			}
		'''.interpretPropagatingErrors
	}

}
