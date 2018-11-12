package org.uqbar.project.wollok.interpreter.context

import java.io.Serializable
import java.util.List
import java.util.Map

/**
 * WExpression evaluation context.
 * This allows to have local variables.
 * It is responsible for resolving variables.
 * 
 * @author jfernandes
 */
interface EvaluationContext<O> extends Serializable {
	
	def O resolve(String name) throws UnresolvableReference
	
	def void setReference(String name, O value)
	def O addReference(String variable, O value) // new local variable
	
	def O addGlobalReference(String name, O value)
	def void removeGlobalReference(String name)
	
	/** Returns an iterable with all available references names from this context */
	def Iterable<WVariable> allReferenceNames()
	
	def O getThisObject()
	def boolean showableInDynamicDiagram(String name)
	def boolean showableInStackTrace()
}

/**
 * Extension methods for evaluation context.
 * Mostly factory methods
 * 
 * @author jfernandes
 */
 //TODO: move to another file
class EvaluationContextExtensions {
	
	def static <O> createEvaluationContext(String name, O value) {
		createEvaluationContext(#[name], value)
	}
	
	def static <O> createEvaluationContext(List<String> names, O... values) {
		var i = 0
		val map = newHashMap
		for (name : names) {
			map.put(name, values.get(i++))
		}
		map.asEvaluationContext
	}
	
	def static <O> asEvaluationContext(Map<String, O> values) { new MapBasedEvaluationContext<O>(values) }
	def static <O> then(EvaluationContext<O> inner, EvaluationContext<O> outer) { new CompositeEvaluationContext<O>(inner, outer) }
	
}