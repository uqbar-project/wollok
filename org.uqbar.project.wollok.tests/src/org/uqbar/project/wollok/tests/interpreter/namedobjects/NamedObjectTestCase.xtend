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
		    var ps = [pepita]
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
			
			assert.equals(pepita, pp.getPs().get(0))
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
				
				const o = new Pepe() 
				
				assert.that(33 == o.getN())
			}'''.interpretPropagatingErrors
			fail("Linking should have failed, 'n' from class Pepe shouldn't have been resolved !")
		}
		catch (AssertionError e) {
			assertTrue(e.message.startsWith("Expected no errors, but got :ERROR (org.eclipse.xtext.diagnostics.Diagnostic.Linking) 'Couldn't resolve reference to Referenciable 'n'.' on WVariableReference"))
		}
	}
	
}