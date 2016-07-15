package org.uqbar.project.wollok.tests.debugger

import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation
import java.util.List

/**
 * A test implementation for the debugger
 * To test the interpreter behavior.
 * 
 * @author jfernandes
 */
@Accessors
class TestDebugger extends XDebuggerOff {
	val WollokInterpreter interpreter
	val List<Pair<EObject, SourceCodeLocation>> evaluated = newArrayList
	
	new(WollokInterpreter interpreter) {
		this.interpreter = interpreter
	}
	
	override evaluated(EObject e) {
		evaluated += (e -> interpreter.stack.peek.currentLocation)
	}
	
}

class LineExpectation {
	val int line
	new(int line) {
		this.line = line
	}
}