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
				method m1() { throw new Exception("hello you see") }
			}
			
			program p {	
				const a = new A()
				
				try {
					a.m2()
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("Wrong message m2() sent to a A[]", e.getMessage())
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
					assert.equals("Wrong argument count in message m1() sent to a A[], however similar definitions exist: m1(a)", e.getMessage())
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
					assert.equals("Wrong argument count in message m1(param1, param2) sent to a A[], however similar definitions exist: m1(a)", e.getMessage())
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
					assert.equals("Wrong argument count in message truncate() sent to 4, however similar definitions exist: truncate(_decimals)", e.getMessage())
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
				method m1() { throw new Exception("hello you see") }
			}
			
			program p {	
				const a = new A()
				
				try {
					a.m2(2, 4)
					assert.fail("Should have thrown message not understood")
				}	
				catch e : MessageNotUnderstoodException {
					// ok !
					assert.equals("Wrong message m2(param1, param2) sent to a A[]", e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
	}
		
	@Test
	def void testCatchWithoutType() {
		'''
			class A { 
				method m1() { throw new Exception("hello you see") }
			}
			
			program p {	
				const a = new A()
				
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
			class AException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			class BException inherits AException {  constructor(m) = super(m) }
			class CException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			
			class A { 
				method m1() { throw new BException("hello you see") }
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
			class AException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			class BException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			
			class A { 
				method m1() { throw new AException("hello you see") }
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
			class AException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			class BException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			
			class A { 
				method m1() { throw new BException("hello you see") }
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
					assert.fail("incorrenct catch !")
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithoutTypeMatchingTheLastCatch() {
		'''
			class AException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			class BException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			class CException inherits wollok.lang.Exception {  constructor(m) = super(m) }
			
			class A { 
				method m1() { throw new CException("hello you see") }
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
					self.error("Gently failling!")
				}
			}
			program p {
				try {
					const f = new C()
					f.foo()
				}
				catch e {
					// OK !
					assert.equals("Gently failling!", e.getMessage())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testExceptionWithMessage(){
		'''
			class UserException inherits wollok.lang.Exception {
			    var valorInvalido = 0
			    
			    constructor(mensaje, value) = super(mensaje) { 	
			    	valorInvalido = value
			    }
			}
			
			object monedero {
			    var plata = 500
			
			    method plata() = return plata
			
			    method poner(cantidad) {
			        if (cantidad < 0) {
			            throw new UserException("La cantidad debe ser positiva", cantidad)
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
					assert.equals("La cantidad debe ser positiva", e.getMessage())
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
					throw new Exception("saldo insuficiente")
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
						throw new Exception("saldo insuficiente")
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
						throw new Exception("saldo insuficiente") 
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
}