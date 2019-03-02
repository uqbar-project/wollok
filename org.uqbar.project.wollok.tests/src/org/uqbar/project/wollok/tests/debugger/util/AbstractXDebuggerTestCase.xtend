package org.uqbar.project.wollok.tests.debugger.util

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Base class for testing the XInterpreter execution in terms of
 * execution steps for scoping, for example.
 * 
 * The main difference with AbstractXDebuggerImplTestCase is that this tests
 * don't use the XDebuggerImpl, but a test implementation.
 * Meaning that you are not testing the execution flow in terms of pausing, 
 * resuming, stepping into, etc.
 * 
 * The are more likely to test the interpreter and not the debugger itself.
 * As the debugger is a just a listener from the interpreter point of view.
 * 
 * @author jfernandes
 */
abstract class AbstractXDebuggerTestCase extends AbstractWollokInterpreterTestCase {
	
	/**
	 * Default handy method for testing a program evaluation step by step.
	 * It returns an object to configure asssertions.
	 * It also sets the debugger into the interpreter.
	 * So you must evaluate a program as any other test with #interpretPropagatinErrors.
	 */
	def debugger() {
		val debugger = new TestDebugger(interpreter)
		interpreter.addInterpreterListener(debugger)
		new DebuggingSessionAsserter(debugger)
	}
	
}