package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokObject
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Tests wollok exceptions handling mechanism.
 * 
 * @author jfernandes
 */
class ExceptionTestCase extends AbstractWollokInterpreterTestCase {

	@Test
	def void testThrowAndCatch() {
		#[		
		'''
			class MyException extends Exception {}
			class A {
				method m1() { throw new MyException() }
			}
			program p {
				val a = new A()
				var counter = 0
				
				try {
					a.m1()
					counter = counter + 1
				}
				catch e : MyException {
					this.println("Exception raised!") // OK!
					e.printStackTrace()
				}
			}
		'''].interpretPropagatingErrors
			
		val counter = interpreter.currentContext.resolve("counter") as WollokObject
		assertEquals(0, counter.asInteger)
	}
	
	@Test
	def void testThenAlwaysExcecutedOnException() {
		'''
			class MyException extends wollok.lang.Exception {}
			class A { method m1() { throw new MyException() } }
		
			program p {	
				val a = new A()
				var counter = 0
				
				try {
					a.m1()
				}
				catch e : MyException
					this.println("Exception raised!") // OK!
				then always
					counter = counter + 1
			}'''.
			interpretPropagatingErrors
			val counter = interpreter.currentContext.resolve("counter") as WollokObject
			assertEquals(1, counter.asInteger)
	}
	
	@Test
	def void testThenAlwaysExcecutedEvenWithoutAnExceptionRaised() {
		'''
			class MyException extends wollok.lang.Exception {}
			class A {
				method m1() {
				}
			}
			
			program p {
				val a = new A()
				var counter = 0
				
				try {
					a.m1()
					counter = counter + 1
				}
				catch e : MyException
					this.println("Exception raised!") // OK!
				then always
					counter = counter + 1 
			}
		'''.
		interpretPropagatingErrors
		val counter = interpreter.currentContext.resolve("counter") as WollokObject
		assertEquals(2, counter.asInteger)
	}

	@Test
	def void testCatchUsingTheExceptionVariable() {
		'''
			class MyException extends wollok.lang.Exception {
				method customMessage() { 
					return "Something went wrong"
				}
			}
			class A { method m1() { throw new MyException() } }

			program p {
				val a = new A()
				var result = null
				
				try {
					a.m1()
				}
				catch e : MyException
					result = e.customMessage()
			}
		'''.interpretPropagatingErrors
		val result = interpreter.currentContext.resolve("result")
		assertEquals("Something went wrong", result)
	}
	
	@Test
	def void testCatchMatchesSubtype() {
		'''
			class MyException extends wollok.lang.Exception {}
			class MySubclassException extends MyException {}
			class A { method m1() { throw new MySubclassException() } }
			
			program p {
				val a = new A()
				var result = 0
				
				try {
					a.m1()
				}
				catch e : MyException
					result = 3
					
				assert.that(3 == result)
				}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testFirstCatchMatches() {
		'''
			class MyException extends wollok.lang.Exception {}
			class MySubclassException extends MyException {}
			class A { method m1() { throw new MySubclassException() } }
			
			program p {	
				val a = new A()
				var result = 0
				
				try 
					a.m1()
				
				catch e : MySubclassException
					result = 3
				catch e : MyException
					result = 2
				assert.that(3 == result)
			}
		'''.interpretPropagatingErrors
	}
}