package org.uqbar.project.wollok.interpreter.context

import java.util.Map

/**
 * Simple EvaluationContext impl backed up by a map.
 * Usualy used for local scopes like methods local variables.
 * 
 * @author jfernandes
 */
class MapBasedEvaluationContext<O> implements EvaluationContext<O> {
	Map<String, O> values
	
	new(Map<String, O> map) {
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

	override setReference(String name, O value) {
		if (!values.containsKey(name))
			// I18N !
			throw new UnresolvableReference("No reference with name " + name)
		values.put(name, value)
	}

	override addReference(String variable, O value) {
		values.put(variable, value)
		value
	}
	
	override addGlobalReference(String name, O value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override removeGlobalReference(String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override toString() {
		class.simpleName + "{" + values.entrySet.map[key + ":" + (if(value===null)"null" else value.class)].join(',') + '}'
	}

	override showableInStackTrace() { true }	
}
