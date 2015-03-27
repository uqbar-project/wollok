package org.uqbar.project.wollok.interpreter.context

import org.uqbar.project.wollok.interpreter.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * Composes two evaluation context in order.
 * Like if one (inner) is inside the other (outer)
 * 
 * @author jfernandes
 */
// es un hack esto que por la interfaz tenga que ejecutar, esperar la exception
// catchear y reenviar a otro contexto.
// Hay que evitar las exceptions que van a relentizar todo.
class CompositeEvaluationContext implements EvaluationContext {
	static val THIS = new WVariable('this', false)
	EvaluationContext inner
	EvaluationContext outer

	new(EvaluationContext inner, EvaluationContext outer) {
		this.inner = inner
		this.outer = outer
	}
	
	override getThisObject() {
		val t = inner.thisObject
		if (t != null) t else outer.thisObject
	}
	
	override allReferenceNames() {
		(if (outer instanceof WollokObject) #[THIS] else outer.allReferenceNames)
			+ inner.allReferenceNames 
	}

	override resolve(String variableName) {
		try
			inner.resolve(variableName)
		catch (UnresolvableReference e)
			outer.resolve(variableName)
	}

	override setReference(String name, Object value) {
		try
			inner.setReference(name, value)
		catch (UnresolvableReference e)
			outer.setReference(name, value)
	}

	override addReference(String name, Object value) {
		inner.addReference(name, value)
		value
	}
	
	override addGlobalReference(String name, Object value) {
		outer.addGlobalReference(name,value)
	}

}
