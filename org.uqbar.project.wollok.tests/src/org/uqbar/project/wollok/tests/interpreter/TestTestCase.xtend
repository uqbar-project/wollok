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

}