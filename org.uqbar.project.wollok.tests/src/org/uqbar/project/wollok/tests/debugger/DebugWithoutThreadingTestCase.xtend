package org.uqbar.project.wollok.tests.debugger

import org.uqbar.project.wollok.tests.debugger.AbstractWollokDebugTestCase
import org.junit.Test

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * Tests the debugger without the sockets communication
 * but also without multithreading (pausing, resuming, stepping, etc).
 * Use a simple listener on the interpreter to find out what it evaluated
 * 
 * @author jfernandes
 */
class DebugWithoutThreadingTestCase extends AbstractWollokDebugTestCase {
	
	@Test
	def void stepByStepEvaluationWithAForEach() {
		val debugger = new TestDebugger(interpreter)
		interpreter.debugger = debugger
		
		'''
		program a {
			const strings = [1, 2, 3]
			var sum = 0
			strings.forEach { s =>
				sum += s
			}
			assert.equals(6, sum)
		}'''.interpretPropagatingErrors
		
		val expected = #[
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
					'/** * Assert object simplifies testing conditions */ object assert { /** * Tests whether value is true. Otherwise throws an exception. * Example: * var number = 7 * assert.that(number.even()) ==> throws an exception "Value was not true" * var anotherNumber = 8 * assert.that(anotherNumber.even()) ==> no effect, ok */ method that(value) native /** Tests whether value is false. Otherwise throws an exception. * @see assert#that(value) */ method notThat(value) native /** * Tests whether two values are equal, based on wollok == method * * Example: * assert.equals(10, 100.div(10)) ==> no effect, ok * assert.equals(10.0, 100.div(10)) ==> no effect, ok * assert.equals(10.01, 100.div(10)) ==> throws an exception */ method equals(expected, actual) native /** Tests whether two values are equal, based on wollok != method */ method notEquals(expected, actual) native /** * Tests whether a block throws an exception. Otherwise an exception is thrown. * * Example: * assert.throwsException({ 7 / 0 }) ==> Division by zero error, it is expected, ok * assert.throwsException("hola".length() ) ==> throws an exception "Block should have failed" */ method throwsException(block) native /** * Throws an exception with a custom message. Useful when you reach an unwanted code in a test. */ method fail(message) native }',
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
		]
		
		assertEquals(expected.size, debugger.evaluated.size)
		
		var i = 0
		for (t : debugger.evaluated) {
//			println(/*t.key.class.simpleName + " >> " + */t.key.sourceCode.replaceAll('\n', ' ').replaceAll('\\s+', ' ').trim()  /* + " >> "+ t.value.contextDescription*/)
			assertEquals(expected.get(i), t.key.sourceCode.replaceAll('\n', ' ').replaceAll('\\s+', ' ').trim())
			i++
		}
		
		
	}
	
}