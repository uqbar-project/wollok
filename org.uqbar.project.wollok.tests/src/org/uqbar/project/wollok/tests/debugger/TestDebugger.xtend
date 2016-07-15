package org.uqbar.project.wollok.tests.debugger

import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.eclipse.emf.ecore.EObject

/**
 * A test implementation for the debugger
 * To test the interpreter behavior.
 * 
 * @author jfernandes
 */
class TestDebugger extends XDebuggerOff {
	val expectations = newArrayList
	
	def atLine(int i) {
		val lineExpectation = new LineExpectation(i)
		expectations.add(lineExpectation)
		lineExpectation
	}
	
	override aboutToEvaluate(EObject element) {
//		eleme
	}
	
}

class LineExpectation {
	val int line
	new(int line) {
		this.line = line
	}
}