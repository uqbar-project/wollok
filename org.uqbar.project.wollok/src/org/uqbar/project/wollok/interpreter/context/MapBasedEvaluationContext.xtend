package org.uqbar.project.wollok.interpreter.context

import java.util.Map
import org.uqbar.project.wollok.interpreter.UnresolvableReference

/**
 * Simple EvaluationContext impl backed up by a map.
 * Usualy used for local scopes like methods local variables.
 * 
 * @author jfernandes
 */
class MapBasedEvaluationContext implements EvaluationContext {
	Map<String, Object> values
	
	new(Map<String, Object> map) {
		values = map
	}
	
	// no this on this kind of evaluation context (you should be using it chained with an outer evaluation context)
	override getThisObject() { null }
	
	override allReferenceNames() {
		values.keySet.map[new WVariable(it, true)]
	}

	override resolve(String variableName) {
		if (!values.containsKey(variableName))
			// I18N !
			throw new UnresolvableReference("No reference with name " + variableName)
		values.get(variableName)
	}

	override setReference(String name, Object value) {
		if (!values.containsKey(name))
			// I18N !
			throw new UnresolvableReference("No reference with name " + name)
		values.put(name, value)
	}

	override addReference(String name, Object value) {
		values.put(name, value)
		value
	}
	
	override addGlobalReference(String name, Object value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}
