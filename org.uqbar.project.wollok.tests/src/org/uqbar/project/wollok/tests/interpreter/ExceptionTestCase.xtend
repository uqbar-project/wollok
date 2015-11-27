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
			
		val counter = interpreter.currentContext.resolve("counter") as WollokObject
		assertEquals(0, counter.asInteger)
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
			val counter = interpreter.currentContext.resolve("counter") as WollokObject
			assertEquals(1, counter.asInteger)
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
		val counter = interpreter.currentContext.resolve("counter") as WollokObject
		assertEquals(2, counter.asInteger)
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
		assertEquals("Something went wrong", result.toString)
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
	
	@Test
	def void testMessageNotUnderstood() {
		'''
			class A { 
				method m1() { throw new Exception("hello you see") }
			}
			
			program p {	
				val a = new A()
				
				try {
					a.m2()
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("a A[] does not understand m2()", e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
		
		// TODO: we need to add tests for the stacktrace generation. I'm not able to match the expected
		// actual stack trace string e.getStackTraceAsString()
	}
	
	@Test
	def void testCatchWithoutType() {
		'''
			class A { 
				method m1() { throw new Exception("hello you see") }
			}
			
			program p {	
				val a = new A()
				
				try {
					a.m1()
					assert.fail("Should have thrown exception")
				}	
				catch e {
					// ok !
					assert.equals("hello you see", e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMultipleMatchingCatchesWillOnlyExecuteTheFirstOne() {
		'''
			class AException inherits wollok.lang.Exception {  new(m) = super(m) }
			class BException inherits AException {  new(m) = super(m) }
			class CException inherits wollok.lang.Exception {  new(m) = super(m) }
			
			class A { 
				method m1() { throw new BException("hello you see") }
			}
			
			program p {	
				val a = new A()
				
				try {
					a.m1()
					assert.fail("Should have thrown exception")
				}	
				catch e : BException {
					// OK !
				}
				catch e : AException {
					assert.fail("incorrenct catch !")
				}
				catch e {
					assert.fail("incorrenct catch !")
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithoutTypeMatchingJustTheFirstCatch() {
		'''
			class AException inherits wollok.lang.Exception {  new(m) = super(m) }
			class BException inherits wollok.lang.Exception {  new(m) = super(m) }
			
			class A { 
				method m1() { throw new AException("hello you see") }
			}
			
			program p {	
				val a = new A()
				
				try {
					a.m1()
					assert.fail("Should have thrown exception")
				}	
				catch e : AException {
					// OK !
				}
				catch e : BException {
					assert.fail("incorrenct catch !")
				}
				catch e {
					assert.fail("incorrenct catch !")
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithoutTypeMatchingJustTheSecondCatch() {
		'''
			class AException inherits wollok.lang.Exception {  new(m) = super(m) }
			class BException inherits wollok.lang.Exception {  new(m) = super(m) }
			
			class A { 
				method m1() { throw new BException("hello you see") }
			}
			
			program p {	
				val a = new A()
				
				try {
					a.m1()
					assert.fail("Should have thrown exception")
				}	
				catch e : AException {
					assert.fail("incorrenct catch !")
				}
				catch e : BException {
					// OK !
				}
				catch e {
					assert.fail("incorrenct catch !")
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithoutTypeMatchingTheLastCatch() {
		'''
			class AException inherits wollok.lang.Exception {  new(m) = super(m) }
			class BException inherits wollok.lang.Exception {  new(m) = super(m) }
			class CException inherits wollok.lang.Exception {  new(m) = super(m) }
			
			class A { 
				method m1() { throw new CException("hello you see") }
			}
			
			program p {	
				val a = new A()
				
				try {
					a.m1()
					assert.fail("Should have thrown exception")
				}	
				catch e : AException {
					assert.fail("incorrect catch !")
				}
				catch e : BException {
					assert.fail("incorrect catch !")
				}
				catch e {
					// OK !
				}
			}
		'''.interpretPropagatingErrors
	}
	
}