package org.uqbar.project.wollok.interpreter.core

import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import static org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*

/**
 * This is a hack but I need to cut the refactor somewhere.
 * The problem here is that all the interpreter code works with WollokObjects
 * both everything is evaluated to a WollokObject, but also parameters to call
 * mest be WollokObjects.
 * In this particular case, the user calls a method but we don't evaluated it
 * before calling.
 * So we pass this weird object that is like and indirection.
 * Before the refactor it was a ()=>WollokObject function which evaluated the content
 * [| interpreter.evaluate()]
 */
class LazyWollokObject extends WollokObject {
	val ()=>WollokObject lazyValue
	var WollokObject evaluated = null
	
	new(IWollokInterpreter interpreter, WMethodContainer behavior, ()=>WollokObject lazyValue) {
		super(interpreter, null) // ?
		this.lazyValue = lazyValue
	}
	
	override call(String message, WollokObject... parameters) {
		if (message !== "eval")
			throw messageNotUnderstood(Messages.WollokInterpreter_lazyValuesOnlySupportEval)
		eval
	}
	
	def synchronized eval() { 
		if (evaluated === null)
			evaluated = lazyValue.apply
		evaluated	
	}
	
}