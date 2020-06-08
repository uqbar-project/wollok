package org.uqbar.project.wollok.interpreter.context

import java.util.List
import java.util.Map

/**
 * Simple EvaluationContext impl backed up by a map.
 * Usually used for local scopes like method local variables.
 * 
 * @author jfernandes
 */
class MapBasedEvaluationContext<O> implements EvaluationContext<O> {
	Map<String, O> values
	List<String> constantValues = newArrayList
	
	new(Map<String, O> map) {
		values = map
	}
	
	// no this on this kind of evaluation context (you should be using it chained with an outer evaluation context)
	override getThisObject() { null }
	
	override allReferenceNames() {
		values.keySet.map[new WVariable(it, null, true, constantValues.contains(it))]
	}

	override allReferenceNamesForDynamicDiagram() {
		this.allReferenceNames.toList
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

	override addReference(String variable, O value, boolean constant) {
		values.put(variable, value)
		if (constant) {
			constantValues.add(variable)
		}
		value
	}
	
	override addGlobalReference(String name, O value, boolean constant) {
		addReference(name, value, constant)
	}
	
	override removeGlobalReference(String name) {
		values.remove(name)
	}
	
	override toString() {
		class.simpleName + "{" + values.entrySet.map[key + ":" + (if(value===null)"null" else value.class)].join(',') + '}'
	}

	override showableInStackTrace() { true }
	
	override variableShowableInDynamicDiagram(String name) { false }

}
