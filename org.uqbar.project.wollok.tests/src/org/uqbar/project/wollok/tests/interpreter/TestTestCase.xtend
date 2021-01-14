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

	@Test
	def void xxx() {
		'''
		class C {
		  var x = y + 1
		  var y = 0
		  
		  method y() = 0
		}
		
		test "test x" {
			assert.equals(new C().y(), 0)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void xxy() {
		'''
		class A {
		  var property a = c + b
		  var property b = 7
		  const property c = b + 1

		  method m() = a + b + c
		}
		
		test "value of a" {
			const a = new A()
			assert.equals(a.a(), 15)
			assert.equals(a.b(), 7)
			assert.equals(a.c(), 8)
			assert.equals(a.m(), 30)
		}
		'''.interpretPropagatingErrors
	}
	
}