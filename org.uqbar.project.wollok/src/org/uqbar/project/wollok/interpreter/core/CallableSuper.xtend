package org.uqbar.project.wollok.interpreter.core

import org.uqbar.project.wollok.interpreter.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.WollokFeatureCallExtensions
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * @author npasserini
 */
class CallableSuper implements WCallable {
	WMethodContainer behavior
	WollokInterpreter interpreter
	
	new(WollokInterpreter interpreter, WMethodContainer behavior) {
		this.interpreter = interpreter
		this.behavior = behavior
	}
	
	override call(String message, Object... parameters) {
		val extension e = new WollokFeatureCallExtensions(receiver) 
		val method = behavior.lookupMethod(message)
		if (method == null)
			throw new MessageNotUnderstood('''Message not understood: «this» does not understand «message»''')
		
		method.call(parameters)
	}
	
	def receiver() { 
		interpreter.stack.peek.context.thisObject as WollokObject //HACKING CAST
	}
	
}