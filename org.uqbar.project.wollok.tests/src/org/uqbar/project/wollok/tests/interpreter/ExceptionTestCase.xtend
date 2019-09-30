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
				const a = new A()
				var counter = 0
				
				try {
					a.m1()
					counter = counter + 1
				}
				catch e : MyException {
					console.println("Exception raised!") // OK!
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
				const a = new A()
				var counter = 0
				
				try {
					a.m1()
				}
				catch e : MyException
					console.println("Exception raised!") // OK!
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
				const a = new A()
				var counter = 0
				
				try {
					a.m1()
					counter = counter + 1
				}
				catch e : MyException
					console.println("Exception raised!") // OK!
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
				const a = new A()
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
				const a = new A()
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
				const a = new A()
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
				method m1() { throw new Exception(message = "hello you see") }
			}
			
			program p {	
				const a = new A()
				
				try {
					a.m2()
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("a A does not understand m2()", e.message())
				}
			}
		'''.interpretPropagatingErrors

		// TODO: we need to add tests for the stacktrace generation. I'm not able to match the expected
		// actual stack trace string e.getStackTraceAsString()
	}

	@Test
	def void testMessageNotUnderstoodHowever1() {
		'''
			class A { 
				method m1(a) { return a + 1 }
			}
			
			program p {	
				const a = new A()
				
				try {
					a.m1()
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("a A does not understand m1(). However other methods exist with different argument count: m1(a)", e.message())
				}
			}
		'''.interpretPropagatingErrors

		// TODO: we need to add tests for the stacktrace generation. I'm not able to match the expected
		// actual stack trace string e.getStackTraceAsString()
	}

	@Test
	def void testMessageNotUnderstoodCaseSensitive() {
		'''
			class A { 
				method m1(a) { return a + 1 }
			}
			
			program p {	
				const a = new A()
				
				try {
					a.M1(3)
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("a A does not understand M1(param1). However other similar methods exist: m1(a)", e.message())
				}
			}
		'''.interpretPropagatingErrors

		// TODO: we need to add tests for the stacktrace generation. I'm not able to match the expected
		// actual stack trace string e.getStackTraceAsString()
	}

	@Test
	def void testMessageNotUnderstoodHowever2() {
		'''
			class A { 
				method m1(a) { return a + 1 }
			}
			
			program p {	
				const a = new A()
				
				try {
					a.m1(2, new Date())
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("a A does not understand m1(param1, param2). However other methods exist with different argument count: m1(a)", e.message())
				}
			}
		'''.interpretPropagatingErrors

		// TODO: we need to add tests for the stacktrace generation. I'm not able to match the expected
		// actual stack trace string e.getStackTraceAsString()
	}

	@Test
	def void testMessageNotUnderstoodWithLiteralsHowever() {
		'''
			program p {	
				try {
					4.truncate()
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("4 does not understand truncate(). However other methods exist with different argument count: truncate(_decimals)", e.message())
				}
			}
		'''.interpretPropagatingErrors

		// TODO: we need to add tests for the stacktrace generation. I'm not able to match the expected
		// actual stack trace string e.getStackTraceAsString()
	}

	@Test
	def void testMessageNotUnderstoodWithLiteralsCaseSensitive() {
		'''
			program p {	
				try {
					4.truncATE(2)
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("4 does not understand truncATE(param1). However other similar methods exist: truncate(_decimals)", e.message())
				}
			}
		'''.interpretPropagatingErrors

		// TODO: we need to add tests for the stacktrace generation. I'm not able to match the expected
		// actual stack trace string e.getStackTraceAsString()
	}
	
	@Test
	def void testMessageNotUnderstoodWithParams() {
		'''
			class A { 
				method m1() { throw new Exception(message = "hello you see") }
			}
			
			program p {	
				const a = new A()
				
				try {
					a.m2(2, 4)
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("a A does not understand m2(param1, param2)", e.message())
				}
			}
		'''.interpretPropagatingErrors
	}
		
	@Test
	def void testCatchWithoutType() {
		'''
			class A { 
				method m1() { throw new Exception(message = "hello you see") }
			}
			
			program p {	
				const a = new A()
				
				try {
					a.m1()
					assert.fail("Should have thrown exception")
				}	
				catch e {
					// ok !
					assert.equals("hello you see", e.message())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testMultipleMatchingCatchesWillOnlyExecuteTheFirstOne() {
		'''
			class AException inherits wollok.lang.Exception {}
			class BException inherits AException {}
			class CException inherits wollok.lang.Exception {}
			
			class A { 
				method m1() { throw new BException(message = "hello you see") }
			}
			
			program p {	
				const a = new A()
				
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
			class AException inherits wollok.lang.Exception {}
			class BException inherits wollok.lang.Exception {}
			
			class A { 
				method m1() { throw new AException(message = "hello you see") }
			}
			
			program p {	
				const a = new A()
				
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
			class AException inherits wollok.lang.Exception {}
			class BException inherits wollok.lang.Exception {}
			
			class A { 
				method m1() { throw new BException(message = "hello you see") }
			}
			
			program p {	
				const a = new A()
				
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
					assert.fail("incorrect catch !")
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithoutTypeMatchingTheLastCatch() {
		'''
			class AException inherits wollok.lang.Exception {}
			class BException inherits wollok.lang.Exception {}
			class CException inherits wollok.lang.Exception {}
			
			class A { 
				method m1() { throw new CException(message = "hello you see") }
			}
			
			program p {	
				const a = new A()
				
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
	
	@Test
	def void testExceptionFromNativeMethodGetsWrappedIntoAWollokException() {
		'''
			program p {
				try {
					console.println(2 / 0)
				}
				catch e : Exception {
					// OK !
					e.printStackTrace()
				}
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testErrorMethodOnWollokObject() {
		'''
			class C {
				method foo() {
					self.error("Gently failing!")
				}
			}
			program p {
				const f = new C()
				try {
					f.foo()
				}
				catch e {
					// OK !
					assert.equals("Gently failing!", e.message())
					assert.equals(f, e.source())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testExceptionWithMessage(){
		'''
			class UserException inherits wollok.lang.Exception {
			    var property valorInvalido = 0
			}
			
			object monedero {
			    var plata = 500
			
			    method plata() = return plata
			
			    method poner(cantidad) {
			        if (cantidad < 0) {
			            throw new UserException(message = "La cantidad debe ser positiva", valorInvalido = cantidad)
			        } 
			        plata += cantidad
			    }
			
			    method sacar(cantidad) { plata -= cantidad }
			}
			
			program p {
				try{
					monedero.poner(-2)
					assert.fail('No should get here')
				} catch e {
					assert.equals("La cantidad debe ser positiva", e.message())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithAReturnStatement() {
		'''
		object cuenta {
			method sacar() {
				try {
					throw new Exception(message = "saldo insuficiente")
				} 
				catch e {
					return 20
				}
			}
		}
		program p {
			assert.equals(20, cuenta.sacar())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithAReturnStatementReturningFromTryBodyAndFromCatch() {
		'''
		object cuenta {
			method sacar(c) {
				try {
					if (c > 0)
						throw new Exception(message = "saldo insuficiente")
					return 19
				} 
				catch e {
					return 20
				}
			}
		}
		program p {
			assert.equals(20, cuenta.sacar(10))
			assert.equals(19, cuenta.sacar(0))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchEvaluationInAShortCutMethod() {
		'''
		object cuenta {
			method sacar(c) = try { 
					if (c > 0) 
						throw new Exception(message = "saldo insuficiente") 
					else 19
				} catch e {
					20
				}
		}
		program p {
			assert.equals(20, cuenta.sacar(10))
			assert.equals(19, cuenta.sacar(0))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void assertThrowsExceptionFailing() {
		'''
		var a = 0
		assert.throwsExceptionLike(
			new AssertionException(message = "Block { a + 1 } should have failed"),
			{ assert.throwsException({ a + 1 }) }
		)
		'''.test
	}
	
	@Test
	def void testCanCreateExceptionUsingNamedParametersWithoutCause() {
		'''
		object unObjeto {
			method prueba() {
				throw new Exception(message = "Saraza")
			}
		}
		'''.interpretPropagatingErrors
	}
	
}