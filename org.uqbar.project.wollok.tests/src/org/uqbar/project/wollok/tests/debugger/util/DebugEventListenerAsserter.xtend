package org.uqbar.project.wollok.tests.debugger.util

import org.junit.Assert
import org.uqbar.project.wollok.debugger.server.rmi.DebugCommandHandler

/**
 * A DebuggerEventListener implementation that
 * performs an assertion and then an action.
 * 
 * Both behaviors are delegated into smaller objects (strategies)
 * to make it more flexible like in  DSL.
 * 
 * Also the condition to perform the assertion and action is also delegated
 * into a third object a DebugEventMatcher
 * 
 * So:
 *  - DebugEventMatcher: knows which point is important to execute this.
 *  - DebugSessionAsserter: knows what to assert
 *  - DebugSessionAction: knows what to do after asserting
 * 
 * @author jfernandes 
 */
class DebugEventListenerAsserter implements DebuggerEventListener {
	DebugSessionAssert assertion = [] // checks nothing by default
	DebugSessionAction action = [] // does nothing by default
	boolean ran = false
	
	protected def void doIt(DebugCommandHandler vm) {
		ran = true
		assertion.doAssert(vm)
		// a little bit of waiting to make sure the interpreter moved on
		// because this doIt() is triggered as a reaction of an interpreter event
		// we don't want the debugger (client) to be ahead of the interpreter (a normal
		// user is not so fast)
		Thread.sleep(50)
		action.execute(vm)
	}

	// dummy impls: subclasses need to override the interesting points
	
	override started(DebugCommandHandler vm) { }
	override terminated(DebugCommandHandler vm) {
		if (!ran)
			Assert.fail("Debug event didn't execute !" + this)
	}
	override suspended(DebugCommandHandler vm) { }
	override resumed(DebugCommandHandler vm) {}
	override breakpointHit(String fileName, int lineNumber, DebugCommandHandler vm) { }
	
	def checkThat((DebugCommandHandler)=>void check) {
		assertion = check
		this
	}
	
	def thenDo((DebugCommandHandler)=>void action) {
		this.action = action
	}
	
	
}