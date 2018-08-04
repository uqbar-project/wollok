package org.uqbar.project.wollok.interpreter.context

/**
 * Composes two evaluation context in order.
 * Like if one (inner) is inside the other (outer)
 * 
 * @author jfernandes
 */
// es un hack esto que por la interfaz tenga que ejecutar, esperar la exception
// catchear y reenviar a otro contexto.
// Hay que evitar las exceptions que van a relentizar todo.
class CompositeEvaluationContext<O> implements EvaluationContext<O> {
	EvaluationContext<O> inner
	EvaluationContext<O> outer

	new(EvaluationContext<O> inner, EvaluationContext<O> outer) {
		this.inner = inner
		this.outer = outer
	}
	
	override getThisObject() {
		val t = inner.thisObject
		if (t !== null) t else outer.thisObject
	}
	
	override allReferenceNames() {
//		(if (outer instanceof WollokObject) #[THIS] else outer.allReferenceNames)
//			+ inner.allReferenceNames 
		outer.allReferenceNames + inner.allReferenceNames 
	}

	override resolve(String variableName) {
		try
			inner.resolve(variableName)
		catch (UnresolvableReference e)
			outer.resolve(variableName)
	}

	override setReference(String name, O value) {
		try
			inner.setReference(name, value)
		catch (UnresolvableReference e)
			outer.setReference(name, value)
	}

	override addReference(String variable, O value) {
		inner.addReference(variable, value)
		value
	}
	
	override addGlobalReference(String name, O value) {
		outer.addGlobalReference(name,value)
	}
	
	override removeGlobalReference(String name) {
		outer.removeGlobalReference(name)
	}
	
	override toString() {
		class.simpleName + "[inner = " + inner.asText + ", outer =" + outer.asText + "]" 
	}

	// avoid a weird stackoverflow 	
	def dispatch asText(CompositeEvaluationContext<O> it) { toString }
	def dispatch asText(MapBasedEvaluationContext<O> it) { toString }
	def dispatch asText(EvaluationContext<O> it) { class.simpleName }
	
	override showableInStackTrace() { true }

}
