package org.uqbar.project.wollok.tests.interpreter.namedobjects

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * @author jfernandes
 */
class NamedObjectTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testMultipleReferencesToSameObjectCreatesJustOneInstance() { '''
		object pp {
		    var ps = #[pepita]
		    method unMethod(){
		        var x = pepita
		        return x
		    }
		
		    method getPs() {
		        return ps
		    }
		}
		
		object pepita {	}
		
		program p {
			pp.unMethod()
			
			this.assertEquals(pepita, pp.getPs().get(0))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testObjectScopingUsingVariableDefinedOutsideOfIt() {
		'''
		program p {
			var n = 33
			
			val o = object {
				method getN() {
					return n
				}
			} 
			
			this.assert(33 == o.getN())
			
			// change N
			n = 34
			
			this.assert(34 == o.getN())
		}'''.interpretPropagatingErrors
	}
	
	
	@Test
	def void testObjectScopingWithClassesFailsOnLinking() {
		try {
			'''
			class Pepe {
				method getN() {
					return n
				}
			}
			program p {
				var n = 33
				
				val o = new Pepe() 
				
				this.assert(33 == o.getN())
			}'''.interpretPropagatingErrors
			fail("Linking should have failed, 'n' from class Pepe shoudln't have been resolved !")
		}
		catch (AssertionError e) {
			assertEquals("Expected no errors, but got :ERROR (org.eclipse.xtext.diagnostics.Diagnostic.Linking) 'Couldn't resolve reference to WReferenciable 'n'.' on WVariableReference\n", e.message)
		}
	}
	
}