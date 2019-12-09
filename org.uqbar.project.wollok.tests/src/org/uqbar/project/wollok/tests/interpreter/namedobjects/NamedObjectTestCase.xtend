package org.uqbar.project.wollok.tests.interpreter.namedobjects

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.api.Test

/**
 * 
 * @author jfernandes
 */
class NamedObjectTestCase extends AbstractWollokInterpreterTestCase {
	
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
			assertTrue(e.message.startsWith("Expected no errors, but got :ERROR (org.eclipse.xtext.diagnostics.Diagnostic.Linking) 'Couldn't resolve reference to 'n'.' on WVariableReference"))
		}
	}
	
}