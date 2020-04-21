package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.AnalysisResultReporter.*

class SyncArgumentsWithParameters extends PropagateMinimalTypes {

	override dispatch analiseVariable(TypeVariable tvar, GenericTypeInfo typeInfo) {
		val supertypes = tvar.messageParameters
		if (supertypes.empty) { return }

		typeInfo.minTypes.statesWithValueDo(Pending, tvar) [
			tvar.propagateMinType(type, supertypes, it)
		]
		
//		TODO: Think better
		supertypes.forEach [ tvarParam |
			if (tvarParam.typeInfo !== null && tvarParam.typeInfo instanceof GenericTypeInfo) {
				val paramMinTypes = (tvarParam.typeInfo as GenericTypeInfo).minTypes
				if (!typeInfo.minTypes.keySet.exists[paramMinTypes.keySet.contains(it)]) { // if no intersection					
					paramMinTypes.statesWithValueDo(Pending, tvarParam) [
						tvarParam.propagateMinType(type, newHashSet(tvar), it)
					]
				} 
			}
		]
		
	}

	override shouldPropagateMinTypes(TypeVariable origin, TypeVariable destination) {
		true
	}

	override targetMinTypeState() {
		Ready
	}

}
