package org.uqbar.project.wollok.interpreter.debugger

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.api.XDebugger

/**
 * Xdebugger impl for the case you run the interpreter
 * without debugging.
 * 
 * Just does nothing
 * 
 * @author jfernandes
 */
class XDebuggerOff implements XDebugger {
	
	override aboutToEvaluate(EObject element) { }
	override evaluated(EObject element) { }
	override started() { }
	override terminated() { }
	
	// control from debugger ui
	
	override terminate() { }
	override stepOver() { }
	override stepInto() { }
	override stepReturn() { }
	override resume() {}
	override pause() {}
	override getStack() {	}
	override setBreakpoint(String fileName, int line) {	}
	override clearBreakpoint(String fileURI, int line) { }
	
}