package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.nativeobj.WollokInteger

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
			class MyException inherits Exception {}
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
			
		val counter = interpreter.currentContext.resolve("counter")
		assertEquals(0, (counter as WollokInteger).wrapped)
	}
	
	@Test
	def void testThenAlwaysExcecutedOnException() {
		'''
			class MyException inherits wollok.lang.Exception {}
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
			val counter = interpreter.currentContext.resolve("counter")
			assertEquals(1, (counter as WollokInteger).wrapped)
	}
	
	@Test
	def void testThenAlwaysExcecutedEvenWithoutAnExceptionRaised() {
		'''
			class MyException inherits wollok.lang.Exception {}
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
		val counter = interpreter.currentContext.resolve("counter")
		assertEquals(2, (counter as WollokInteger).wrapped)
	}

	@Test
	def void testCatchUsingTheExceptionVariable() {
		'''
			class MyException inherits wollok.lang.Exception {
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
			class MyException inherits wollok.lang.Exception {}
			class MySubclassException inherits MyException {}
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
			class MyException inherits wollok.lang.Exception {}
			class MySubclassException inherits MyException {}
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