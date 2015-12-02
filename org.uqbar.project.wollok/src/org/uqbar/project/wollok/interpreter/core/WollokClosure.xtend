package org.uqbar.project.wollok.interpreter.core

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.wollokDsl.WClosure

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*

/**
 * A closure runtime native object
 * 
 * @author jfernandes
 */
 //REVIEWME: tiene cosas parecidas a la ejecución de un método en WollokObject
class WollokClosure implements WCallable {
	extension WollokInterpreter interpreter
	WClosure closure
	EvaluationContext container
	
	new(WClosure closure, WollokInterpreter interpreter) {
		this.closure = closure
		this.interpreter = interpreter
		this.container = interpreter.currentContext
	}
	
	override call(String message, Object... parameters) {
		if (message != "apply") throw throwMessageNotUnderstood(this, message, parameters)
		apply(parameters)
	}
	
	// REPEATED code: will be deleted once we migrate closures to be modeled in wollok
	def throwMessageNotUnderstood(Object nativeObject, String name, Object[] parameters) {
		new WollokProgramExceptionWrapper((interpreter.evaluator as WollokInterpreterEvaluator).newInstance(MESSAGE_NOT_UNDERSTOOD_EXCEPTION, "Closures don't understand message " + name))
	}
	
	def Object apply(Object... arguments) {
		val context = closure.createEvaluationContext(arguments).then(container)
		interpreter.performOnStack(closure, context) [|
			interpreter.eval(closure.expression)
		]
	}
	
	def static createEvaluationContext(WClosure c, Object... values) { c.parameterNames.createEvaluationContext(values) }
	
	def static getParameterNames(WClosure it) { parameters.map[name] }
	def getParameters() { closure.parameters }

	override toString() {
		"aClosure(" + parameters.map[name].join(', ') + ")"
	}
}