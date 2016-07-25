package org.uqbar.project.wollok.tests.debugger

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.Test
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

import static org.junit.Assert.*

import static extension org.uqbar.project.wollok.tests.debugger.util.DebuggingSessionAsserter.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * Tests the debugger without the sockets communication
 * but also without multithreading (pausing, resuming, stepping, etc).
 * Use a simple listener on the interpreter to find out what it evaluated
 * 
 * This test was kind of first start to increase "coverage" in debugger testing.
 * But it is fragile and very simplistic.
 * Just asserts on a given execution evaluated code.
 * 
 * @author jfernandes
 */
class DebugWithoutThreadingTestCase extends AbstractWollokInterpreterTestCase {
	
	def debugger() {
		val debugger = new PostEvaluationTestDebugger(interpreter)
		interpreter.debugger = debugger
		debugger
	}
	
	@Test
	def void evaluatedCalled() {
		val deb = debugger()
		deb.childrenFirst = true
		
		'''
		program a {
			const strings = [1, 2, 3]
			var sum = 0
			strings.forEach { s =>
				sum += s
			}
			assert.equals(6, sum)
		}'''.interpretPropagatingErrors
		
		deb
			.assertEvaluated(#[
			// program
					"1",
					"2",
					"3",
					"[1, 2, 3]",
				"const strings = [1, 2, 3]",
					"0",
				"var sum = 0",
					"strings",
					"{ s => sum += s }",
					// method forEach(closure) { self.fold(null, { acc, e => closure.apply(e) }) }
						"self",
						"null",
						"{ acc, e => closure.apply(e) }",
						"closure",
						"e",
						// closure 1st time
						"sum",
						"s",
						"sum += s",
						"sum += s",
						"closure.apply(e)",
						"closure.apply(e)",
						"closure",
						"e",
						// closure 2st time
						"sum",
						"s",
						"sum += s",
						"sum += s",
						"closure.apply(e)",
						"closure.apply(e)",
						"closure",
						"e",
						// closure 3rd time
						"sum",
						"s",
						"sum += s",
						"sum += s",
						"closure.apply(e)",
						"closure.apply(e)",
						"self.fold(null, { acc, e => closure.apply(e) })",
						"{ self.fold(null, { acc, e => closure.apply(e) }) }",
						"strings.forEach { s => sum += s }",
						assertCode(),
				// calling assert
					"assert",
					"6",
					"sum",
					// call
					// method equals(expected, actual) native 
						"other",
						"null",
						"other != null",
						"self",
						"other",
						"self === other",
						"other != null && self === other",
						"return other != null && self === other",
						"{ return other != null && self === other }",
				"assert.equals(6, sum)",
			"program a { const strings = [1, 2, 3] var sum = 0 strings.forEach { s => sum += s } assert.equals(6, sum) }"
		])
	}
	
	@Test
	def void aboutToEvaluateCalled() {
		val deb = debugger()
		deb.childrenFirst = false 
		'''
		program a {
			const strings = [1, 2, 3]
			var sum = 0
			strings.forEach { s =>
				sum += s
			}
			assert.equals(6, sum)
		}'''.interpretPropagatingErrors
		
		deb
			.assertEvaluated(#[
				"program a { const strings = [1, 2, 3] var sum = 0 strings.forEach { s => sum += s } assert.equals(6, sum) }",
					"const strings = [1, 2, 3]",
						"[1, 2, 3]",
							"1",
							"2",
							"3",
					"var sum = 0",
						"0",
					"strings.forEach { s => sum += s }",
						"strings",
						"{ s => sum += s }",
						// forEach
						"{ self.fold(null, { acc, e => closure.apply(e) }) }",
							"self.fold(null, { acc, e => closure.apply(e) })",
								"self",
								"null",
								"{ acc, e => closure.apply(e) }",
									// fold (1st)
									"closure.apply(e)",
									"closure.apply(e)",
										"closure",
										"e",
											// closure apply
											"sum += s",
											"sum += s",
												"sum",
												"s",
									// fold (2nd)
									"closure.apply(e)",
									"closure.apply(e)",
										"closure",
										"e",
											// closure apply
											"sum += s",   // why is it duplicated ?
											"sum += s",
												"sum",
												"s",
									// fold (3rd)
									"closure.apply(e)",
									"closure.apply(e)",
										"closure",
										"e",
											// closure apply
											"sum += s",
											"sum += s",
												"sum",
												"s",
						"assert.equals(6, sum)",
							// target and args
							"assert",
							assertCode(),
							"6",
							"sum",
							// body
							"{ return other != null && self === other }",
								"return other != null && self === other",
									"other != null && self === other",
										"other != null",
											"other",
											"null",
									"self === other",
										"self",
											"other"
		])
	}
	
	def assertCode(){
'''/**
 * Assert object simplifies testing conditions
 */
object assert {

	/** 
	 * Tests whether value is true. Otherwise throws an exception.
	 * Example:
	 * 		var number = 7
	 *		assert.that(number.even())   ==> throws an exception "Value was not true"
	 * 		var anotherNumber = 8
	 *		assert.that(anotherNumber.even())   ==> no effect, ok		
	 */
	method that(value) native
	
	/** Tests whether value is false. Otherwise throws an exception. 
	 * @see assert#that(value) 
	 */
	method notThat(value) native
	
	/** 
	 * Tests whether two values are equal, based on wollok == method
	 * 
	 * Example:
	 *		 assert.equals(10, 100.div(10)) ==> no effect, ok
	 *		 assert.equals(10.0, 100.div(10)) ==> no effect, ok
	 *		 assert.equals(10.01, 100.div(10)) ==> throws an exception 
	 */
	method equals(expected, actual) native
	
	/** Tests whether two values are equal, based on wollok != method */
	method notEquals(expected, actual) native
	
	/** 
	 * Tests whether a block throws an exception. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		assert.throwsException({ 7 / 0 })  ==> Division by zero error, it is expected, ok
	 *		assert.throwsException("hola".length() ) ==> throws an exception "Block should have failed"
	 */
	method throwsException(block) native
	
	/** 
	 * Tests whether a block throws an exception and this is the same expected. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		
	 *		assert.throwsExceptionLike(new BusinessException("hola"),{ => throw new BusinessException("hola") } => Works! this is the same exception class and same message.
	 *		assert.throwsExceptionLike(new BusinessException("chau"),{ => throw new BusinessException("hola") } => Doesn't work. This is the same exception class but got a different message.
	 *		assert.throwsExceptionLike(new OtherException("hola"),{ => throw new BusinessException("hola") } => Doesn't work. This isn't the same exception class although it contains the same message.
	 */	 
	method throwsExceptionLike(exceptionExpected, block) {
		try 
		{
			self.throwsExceptionByComparing( block,{a => a.equals(exceptionExpected)})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new OtherValueExpectedException("The Exception expected was " + exceptionExpected + " but got " + ex.getCause())
		} 
	}

	/** 
	 * Tests whether a block throws an exception and it have the error message as is expected. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		
	 *		assert.throwsExceptionWithMessage("hola",{ => throw new BusinessException("hola") } => Works! this is the same message.
	 *		assert.throwsExceptionWithMessage("hola",{ => throw new OtherException("hola") } => Works! this is the same message.
	 *		assert.throwsExceptionWithMessage("chau",{ => throw new BusinessException("hola") } => Doesn't work. This is the same exception class but got a different message.
	 */	 
	method throwsExceptionWithMessage(errorMessage, block) {
		try 
		{
			self.throwsExceptionByComparing(block,{a => errorMessage.equals(a.getMessage())})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new OtherValueExpectedException("The error message expected was " + errorMessage + " but got " + ex.getCause().getMessage())
		}
	}

	/** 
	 * Tests whether a block throws an exception and this is the same exception class expected. Otherwise an exception is thrown.
	 *
	 * Example:
	 * 		
	 *		assert.throwsExceptionWithType(new BusinessException("hola"),{ => throw new BusinessException("hola") } => Works! this is the same exception class.
	 *		assert.throwsExceptionWithType(new BusinessException("chau"),{ => throw new BusinessException("hola") } => Works again! this is the same exception class.
	 *		assert.throwsExceptionWithType(new OtherException("hola"),{ => throw new BusinessException("hola") } => Doesn't work. This isn't the same exception class although it contains the same message.
	 */	 	
	method throwsExceptionWithType(exceptionExpected, block) {
		try 
		{
			self.throwsExceptionByComparing(block,{a => exceptionExpected.className().equals(a.className())})
		}
		catch ex : OtherValueExpectedException 
		{
			throw new OtherValueExpectedException("The exception expected was " + exceptionExpected.className() + " but got " + ex.getCause().className())
		}
	}

	/** 
	 * Tests whether a block throws an exception and compare this exception with other block called comparison. Otherwise an exception is thrown.
	 * The block comparison have to receive a value (an exception thrown) that is compared in a boolean expression returning the result.
	 *
	 * Example:
	 * 		
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{a => "hola".equals(a.getMessage())}} => Works!.
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{a => new BusinessException("lele").className().equals(a.className())} } => Works again!
	 *		assert.throwsExceptionByComparing({ => throw new BusinessException("hola"),{a => "chau!".equals(a.getMessage())} } => Doesn't work. The block evaluation resolve a false value.
	 */		
	method throwsExceptionByComparing(block,comparison){
		var continue = false
		try 
			{
				block.apply()
				continue = true
			} 
		catch ex 
			{
				if(comparison.apply(ex))
					assert.that(true)
				else
					throw new OtherValueExpectedException("Expected other value", ex)
			}
		if (continue) throw new Exception("Should have thrown an exception")	
	}
	/**
	 * Throws an exception with a custom message. Useful when you reach an unwanted code in a test.
	 */
	method fail(message) native
	
}
'''.toString.replaceAll('\n', ' ').replaceAll('\\s+', ' ').trim()		
	}
}

@Accessors
class PostEvaluationTestDebugger extends XDebuggerOff {
	var boolean childrenFirst = true
	var boolean logSession = false
	val List<Pair<EObject, XStackFrame>> evaluated = newArrayList
	WollokInterpreter interpreter
	
	new(WollokInterpreter interpreter) {
		this.interpreter = interpreter
	}
	
	override aboutToEvaluate(EObject element) {
		if (!childrenFirst)
			store(element)
	}
	
	override evaluated(EObject element) {
		if (childrenFirst)
			store(element)
	}
	
	def store(EObject element) {
		if (logSession)
			println('"' + element.sourceCode.replaceAll('\n', ' ').replaceAll('\\s+', ' ').trim() + '",')
		evaluated += (element -> interpreter.stack.peek.clone)
	}
	
		/**
	 * This method is for backward compatibility in tests.
	 * It is expected to be called AFTER execution
	 */
	def assertEvaluated(List<String> expected) {
		assertEquals(expected.size, evaluated.size)
		
		var i = 0
		for (t : evaluated) {
			val escaped = t.key.escapedCode 
			if (logSession)
				println(escaped)
			assertEquals(expected.get(i), escaped)
			i++
		}
	}
	
}