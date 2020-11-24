package org.uqbar.project.wollok.tests.interpreter

import org.junit.Assert
import org.junit.Test
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*

/**
 * @author tesonep
 * @author jfernandes
 */
class TestTestCase extends AbstractWollokInterpreterTestCase {

	@Test
	def void cannotResolveReferenceIssue1376() {
		try {
			'''
			object pepita {
				method volar() {
					pepa.volar()
				}
			}
			
			test "testX" {
				pepita.volar()
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			fail("Should have failed with unresolved reference to pepa")
		} catch (WollokInterpreterException e) {
			Assert.assertEquals("Couldn't resolve reference to pepa", e.originalCause.message)
		}
	}
	
	@Test
	def void cannotResolveReference_2_Issue1376() {
		try {
			'''
			object pepita {
				method volar() {
					pepa + 1
				}
			}
			
			test "testX" {
				pepita.volar()
			}
			'''.interpretPropagatingErrorsWithoutStaticChecks
			fail("Should have failed with unresolved reference to pepa")
		} catch (WollokInterpreterException e) {
			Assert.assertEquals("Couldn't resolve reference to pepa", e.originalCause.message)
		}
	}

	// BORRAR
	@Test
	def void tx() {
		'''
		class C {
		  var property a = 1
		  var property b = a + 1
		}
		
		describe "lazy initialization on instances" {
		
		  test "overriding default initialization: variable -> value" {
		    assert.equals(3, new C(a = 2).b())
		  }
		
		}
		'''.interpretPropagatingErrors		
	}	
}