package org.uqbar.project.wollok.interpreter.context

import java.util.Map
import org.uqbar.project.wollok.interpreter.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * Simple EvaluationContext impl backed up by a map.
 * Usualy used for local scopes like methods local variables.
 * 
 * @author jfernandes
 */
class MapBasedEvaluationContext implements EvaluationContext {
	Map<String, WollokObject> values
	
	new(Map<String, WollokObject> map) {
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

	override setReference(String name, WollokObject value) {
		if (!values.containsKey(name))
			// I18N !
			throw new UnresolvableReference("No reference with name " + name)
		values.put(name, value)
	}

	override addReference(String variable, WollokObject value) {
		values.put(variable, value)
		value
	}
	
	override addGlobalReference(String name, WollokObject value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}
