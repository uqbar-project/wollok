package org.uqbar.project.wollok.interpreter.core

import org.uqbar.project.wollok.interpreter.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.interpreter.AbstractWollokCallable

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
	
	override call(String message, Object... parameters) {
		val method = behavior.lookupMethod(message)
		if (method == null)
			// I18N !
			throw new MessageNotUnderstood('''Message not understood: «this» does not understand «message»(«parameters.map["p"].join(',')»)''')
		
		method.call(parameters)
	}
	
	override getReceiver() { 
		(interpreter as WollokInterpreter).stack.peek.context.thisObject as WollokObject //HACKING CAST
	}
}