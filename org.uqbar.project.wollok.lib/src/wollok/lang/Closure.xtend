package wollok.lang

import java.util.List
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.interpreter.nativeobj.NodeAware
import org.uqbar.project.wollok.sdk.WollokDSK
import org.uqbar.project.wollok.wollokDsl.WClosure

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * 
 * @author jfernandes
 */
class Closure implements NodeAware<WClosure>, Function1<WollokObject, Object> {
	@Accessors WClosure EObject
	extension WollokInterpreter interpreter
	WollokObject obj
	EvaluationContext container
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
		this.container = interpreter.currentContext
	}
	
	def closure() { 
		EObject
	}
	
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
	
	def static createEvaluationContext(WClosure c, WollokObject... values) {
		if (values.size !== c.parameters.size) {
			throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_ARGUMENTS_SIZE_IN_CLOSURE, c.parameters.size, values.size))
		} 
		c.parameterNames.createEvaluationContext(values)
	}
	
	def static getParameterNames(WClosure it) { parameters.map[name] }
	def getParameters() { closure.parameters }
	
	override toString() {
		closure.astNode?.text?.trim
	}
	
}