package wollok.lang

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NodeAware

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import java.util.List
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

/**
 * Native class implementation for wollok.lang.Closure
 * 
 * @author jfernandes
 */
class Closure implements NodeAware<org.uqbar.project.wollok.wollokDsl.WClosure>, Function1<WollokObject, Object> {
	@Accessors org.uqbar.project.wollok.wollokDsl.WClosure EObject
	extension WollokInterpreter interpreter
	WollokObject obj
	EvaluationContext container
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
		this.container = interpreter.currentContext
	}
	
	def closure() { EObject }
	
	// REVIEW: all the convertions between list, array, etc
	
	override Object apply(WollokObject args) {
		val list = (args.wollokToJava(List) as List<WollokObject>)
		val arguments = list.toArray(<WollokObject>newArrayOfSize(list.size))
		doApply(arguments)
	}

	@NativeMessage("apply")	
	def doApply(WollokObject... args) {
		val context = closure.createEvaluationContext(args).then(container)
		interpreter.performOnStack(closure, context) [|
			interpreter.eval(closure.expression)
		]	
	}
	
	@NativeMessage("while")
	def _while(WollokObject predicate) {
		val pred = predicate.asClosure
		do {
			doApply
		} while (pred.doApply.wollokToJava(Boolean) as Boolean)
	}
	
	def static createEvaluationContext(org.uqbar.project.wollok.wollokDsl.WClosure c, WollokObject... values) { c.parameterNames.createEvaluationContext(values) }
	
	def static getParameterNames(org.uqbar.project.wollok.wollokDsl.WClosure it) { parameters.map[name] }
	def getParameters() { closure.parameters }
	
	override toString() {
		"aClosure(" + parameters.map[name].join(', ') + ")"
	}
	
}