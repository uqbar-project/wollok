package org.uqbar.project.wollok.interpreter.context

import java.io.Serializable
import java.util.List
import java.util.Map
import org.uqbar.project.wollok.interpreter.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.WCallable

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