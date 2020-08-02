package org.uqbar.project.wollok.tests.debugger

import org.junit.Test
import org.uqbar.project.wollok.tests.debugger.util.AbstractXDebuggerTestCase

import static org.uqbar.project.wollok.tests.debugger.util.asserters.Asserters.*
import static org.uqbar.project.wollok.tests.debugger.util.DebuggingSessionAsserter.*

/**
 * Tests the interpreter evaluation asserting the evaluation context (scope)
 * in terms of present variables, and values.
 * 
 * @author jfernandes
 */
class InterpreterRuntimeScopingTestCase extends AbstractXDebuggerTestCase {
	
	// TODO: add more tests
	
	@Test
	def void aLocalVariableWillBeAvailableInAProgramScopeJustAfterItsDecl() {
		debugger()
			.assertThat
				.before [
					matching(codeIs("var a = 23"))
					expect(noVariables)	
				]
				.after [
					matching(codeIs("var a = 23"))
					expect(variable("a", "23"))	
				]
				.before [
					matching(codeIs("var b = 2"))
					expect(variable("a", "23"))
				]
				
		'''
		program myprogram {
			var a = 23
			var b = 2
		}
		'''.interpretPropagatingErrors
	}

}
