package org.uqbar.project.wollok.tests.debugger.util

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff

/**
 * A test implementation for the debugger
 * To test the interpreter behavior.
 * 
 * You must setup assertion by adding them #addAssertion
 * 
 * @see InterpreterAssertion
 * 
 * Then this class just listens to the interpreter and evaluates
 * each assertion.
 * 
 * @author jfernandes
 */
@Accessors
class TestDebugger extends XDebuggerOff {
	val WollokInterpreter interpreter
	List<InterpreterAssertion> assertions = newArrayList
	
	new(WollokInterpreter interpreter) {
		this.interpreter = interpreter
	}
	
	override aboutToEvaluate(EObject element) {
		assertions.forEach[ before(element -> interpreter.stack.peek) ]
	}
	
	override evaluated(EObject element) {
		assertions.forEach[ after(element -> interpreter.stack.peek) ]	
	}
	
	def addAssertion(InterpreterAssertion assertion) {
		assertions += assertion
	}
	
}