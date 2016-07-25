package org.uqbar.project.wollok.tests.debugger.util

/**
 * @author jfernandes
 */
interface DebuggerEventAssertion {
	
	def DebugEventListenerAsserter on(DebugEventListenerAsserter matcher)
	
}