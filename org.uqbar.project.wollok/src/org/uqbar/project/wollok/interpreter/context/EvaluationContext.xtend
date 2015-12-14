package org.uqbar.project.wollok.interpreter.context

import java.io.Serializable
import java.util.List
import java.util.Map
import org.uqbar.project.wollok.interpreter.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * WExpression evaluation context.
 * This allows to have local variables.
 * It is responsible for resolving variables.
 * 
 * @author jfernandes
 */
interface EvaluationContext extends Serializable {
	def WollokObject resolve(String name) throws UnresolvableReference
	def void setReference(String name, WollokObject value)
	def WollokObject addReference(String variable, WollokObject value) // new local variable
	def WollokObject addGlobalReference(String name, WollokObject value)
	
	/** Returns an iterable with all available references names from this context */
	def Iterable<WVariable> allReferenceNames()
	
	def WollokObject getThisObject()
}

/**
 * Extension methods for evaluation context.
 * Mostly factory methods
 * 
 * @author jfernandes
 */
 //TODO: move to another file
class EvaluationContextExtensions {
	
	def static createEvaluationContext(String name, WollokObject value) {
		createEvaluationContext(#[name], value)
	}
	
	def static createEvaluationContext(List<String> names, WollokObject... values) {
		var i = 0
		val map = newHashMap
		for (name : names) {
			map.put(name, values.get(i++))
		}
		map.asEvaluationContext
	}
	
	def static asEvaluationContext(Map<String, WollokObject> values) { new MapBasedEvaluationContext(values) }
	def static then(EvaluationContext inner, EvaluationContext outer) { new CompositeEvaluationContext(inner, outer) }
	
}