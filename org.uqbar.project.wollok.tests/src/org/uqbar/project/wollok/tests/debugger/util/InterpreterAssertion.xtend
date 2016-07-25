package org.uqbar.project.wollok.tests.debugger.util

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.tests.debugger.util.asserters.InterpreterAsserter
import org.uqbar.project.wollok.tests.debugger.util.matchers.InterpreterElementMatcher

/**
 * An strategy object used by the test debugger
 * to forward events while evaluating.
 * 
 * This objects will execute any assertion if needed.
 * 
 * You configure it by given two aspects:
 *  
 *   - a matcher: which will know which places are interesting for this assertion
 *   - an asserter: that knows what to check for 
 * 
 * @see matching
 * @see expect
 * 
 * @author jfernandes
 */
interface InterpreterAssertion {
	
	// interface for the end-user configuring this assertion
	
	/**
	 * Sets this assertion particular assert.
	 */
	def InterpreterAssertion matching(InterpreterElementMatcher asserter)
	
	/**
	 * Sets this assertion particular assert.
	 */
	def InterpreterAssertion expect(InterpreterAsserter asserter)
	
	// interface called by the test debugger while executing
	
	/** 
	 * Called by the test debugger. If the assertion is interested in this event then
	 * it will perform an assertion.
	 */
	def void before(Pair<EObject, XStackFrame> state);
	
	/** 
	 * Called by the test debugger. If the assertion is interested in this event then
	 * it will perform an assertion.
	 */
	def void after(Pair<EObject, XStackFrame> state);
	
}