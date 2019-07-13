package org.uqbar.project.wollok.interpreter.core

import org.uqbar.project.wollok.interpreter.AbstractWollokCallable
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

/**
 * The receiver of a "super" feature call.
 * 
 * @author npasserini
 */
class CallableSuper extends AbstractWollokCallable {
	WMethodContainer behavior
	
	new(WollokInterpreter interpreter, WMethodContainer behavior) {
		super(interpreter, behavior)
		this.behavior = behavior
	}
	
	override call(String message, WollokObject... parameters) {
		receiver.callSuper(behavior, message, parameters)
	}
	
	override getReceiver() { 
		(interpreter as WollokInterpreter).currentThread.stack.peek.context.thisObject
	}
}