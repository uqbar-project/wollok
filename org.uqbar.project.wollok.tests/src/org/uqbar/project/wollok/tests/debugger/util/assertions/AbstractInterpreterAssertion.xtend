package org.uqbar.project.wollok.tests.debugger.util.assertions

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.tests.debugger.util.InterpreterAssertion
import org.uqbar.project.wollok.tests.debugger.util.asserters.InterpreterAsserter
import org.uqbar.project.wollok.tests.debugger.util.matchers.InterpreterElementMatcher

/**
 * Abstract base class for assertions.
 * It is composed of two other objects:
 * 
 * - matcher: knows if the executing point is interesting for this assertion. The "were"
 * - asserter: knows what to assert.
 * 
 * For example:
 *   - on each method call
 *   - assert that none of the parameters are null
 * 
 * @see InterpreterElementMatcher
 * @see InterpreterAsserter
 * 
 * @author jfernandes
 */
abstract class AbstractInterpreterAssertion implements InterpreterAssertion {
	var InterpreterElementMatcher matcher
	var InterpreterAsserter asserter
	
	protected def checkAndAssert(Pair<EObject, XStackFrame> state) {
		if (matcher === null) throw new RuntimeException("You didn't set any matcher to this assertion !")
		if (asserter === null) throw new RuntimeException("You didn't set any asserter to this assertion !")
		
		if (matcher.matches(state))
			asserter.assertIt(state)
	}
	
	override expect(InterpreterAsserter asserter) {
		this.asserter = asserter
		this
	}
	
	override matching(InterpreterElementMatcher matcher) {
		this.matcher = matcher
		this
	}
	
	override before(Pair<EObject, XStackFrame> state) {
		// does nothing
	}
	
	override after(Pair<EObject, XStackFrame> state) {
		// does nothing
	}
	
}