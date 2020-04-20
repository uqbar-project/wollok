package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.AnalysisResultReporter.*

class SyncArgumentsWithParameters extends PropagateMinimalTypes {

	override dispatch analiseVariable(TypeVariable tvar, GenericTypeInfo typeInfo) {
		val supertypes = tvar.messageParameters
		if (supertypes.empty) { return }

		supertypes.forEach [
			if (it.typeInfo !== null) {				
				(it.typeInfo as GenericTypeInfo).minTypes.statesWithValueDo(Pending, it) [
					tvar.propagateMinType(type, newHashSet(tvar), it)
				]
			}
		]

		typeInfo.minTypes.statesWithValueDo(Pending, tvar) [
			tvar.propagateMinType(type, supertypes, it)
		]
	}

	override shouldPropagateMinTypes(TypeVariable origin, TypeVariable destination) {
		true
	}

	override targetMinTypeState() {
		Ready
	}

}
