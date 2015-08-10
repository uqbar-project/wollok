package org.uqbar.project.wollok.interpreter.core

import org.uqbar.project.wollok.interpreter.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.UnresolvableReference
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.wollokDsl.WClosure

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*

/**
 * A closure runtime native object
 * 
 * @author jfernandes
 */
 //REVIEWME: tiene cosas parecidas a la ejecución de un método en WollokObject
class WollokClosure implements EvaluationContext, WCallable {
	extension WollokInterpreter interpreter
	WClosure closure
	EvaluationContext container
	
	new(WClosure closure, WollokInterpreter interpreter) {
		this.closure = closure
		this.interpreter = interpreter
		this.container = interpreter.currentContext
	}
	
	override getThisObject() { container.thisObject }
	
	def getParameters() {
		closure.parameters
	}
	
	override allReferenceNames() {
		closure.parameterNames.map[new WVariable(it, true)] + container.allReferenceNames
	}
	
	override call(String message, Object... parameters) {
		if (message == "apply")
			apply(parameters)
		else
			// I18N !
			throw new MessageNotUnderstood('''Closure objects don't understand message "«message»" ''')
	}
	
	def Object apply(Object... arguments) {
		val context = closure.createEvaluationContext(arguments).then(container)
		interpreter.performOnStack(closure, context) [|
			interpreter.eval(closure.expression)
		]
	}
	
	def static createEvaluationContext(WClosure c, Object... values) {
		c.parameterNames.createEvaluationContext(values)
	}
	
	def static parameterNames(WClosure c) {
		c.parameters.map[name]
	}


	// unimplemented methods
	
	override addReference(String variable, Object value) {
		throw new UnresolvableReference(variable)
	}
	
	// a closure doesn't have a static state.
	// an evaluation context is newly created on each "apply()" call
	override resolve(String name) throws UnresolvableReference {
		throw new UnresolvableReference(name)
	}
	
	override setReference(String name, Object value) {
		throw new UnresolvableReference(name)
	}
	
	override addGlobalReference(String name, Object value) {
		container.addGlobalReference(name,value)
	}
	
}