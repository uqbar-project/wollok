package org.uqbar.project.wollok.interpreter.context

import java.io.Serializable
import java.util.List
import java.util.Map
import java.util.Stack
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFeatureCall

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * WExpression evaluation context.
 * This allows to have local variables.
 * It is responsible for resolving variables.
 * 
 * @author jfernandes
 */
interface EvaluationContext extends Serializable {
	def Object resolve(String name) throws UnresolvableReference
	def void setReference(String name, Object value)
	def Object addReference(String name, Object value) // new local variable
	def Object addGlobalReference(String name, Object value)
	
	/** Returns an iterable with all available references names from this context */
	def Iterable<WVariable> allReferenceNames()
	
	def WCallable getThisObject()
}


class UnresolvableReference extends RuntimeException {
	new(String message) {
		super(message)
	}
}

class MessageNotUnderstood extends RuntimeException {
	// Esto es previo a tener la infraestructura de debugging
	// probablemente seria bueno unificar el manejo de errores con eso
	var Stack<WFeatureCall> wollokStack = new Stack
	
	new(String message) {
		super(message)
	}
	
	def pushStack(WFeatureCall call) { wollokStack.push(call) }
	
	override getMessage() '''«super.getMessage()»
		«FOR m : wollokStack»
		«(m as WExpression).method?.declaringContext?.contextName».«(m as WExpression).method?.name»():«NodeModelUtils.findActualNodeFor(m).textRegionWithLineInformation.lineNumber»
		«ENDFOR»
	'''
	
}

/**
 * Extension methods for evaluation context.
 * Mostly factory methods
 * 
 * @author jfernandes
 */
 //TODO: move to another file
class EvaluationContextExtensions {
	
	def static createEvaluationContext(String name, Object value) {
		createEvaluationContext(#[name], value)
	}
	
	def static createEvaluationContext(List<String> names, Object... values) {
		var i = 0
		val map = newHashMap
		for (name : names) {
			map.put(name, values.get(i++))
		}
		map.asEvaluationContext
	}
	
	def static asEvaluationContext(Map<String, Object> values) { new MapBasedEvaluationContext(values) }
	def static then(EvaluationContext inner, EvaluationContext outer) { new CompositeEvaluationContext(inner, outer) }
}