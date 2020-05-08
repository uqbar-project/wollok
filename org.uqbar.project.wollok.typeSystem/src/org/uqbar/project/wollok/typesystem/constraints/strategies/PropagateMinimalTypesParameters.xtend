package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.AnalysisResultReporter.*

class PropagateMinimalTypesParameters extends PropagateMinimalTypes {

	override dispatch analiseVariable(TypeVariable tvar, GenericTypeInfo typeInfo) {
		if (tvar.messageParameters.empty) {
			return
		}

		tvar.propagateMinTypesToParameters(typeInfo)
		tvar.propagateMinTypesFromParameters(typeInfo)
	}
	
	def propagateMinTypesToParameters(TypeVariable tvar, GenericTypeInfo typeInfo) {
		val supertypes = tvar.messageParameters
		typeInfo.minTypes.statesWithValueDo(Pending, tvar) [
			tvar.propagateMinType(type, supertypes, it)
		]		
	}
	
	def propagateMinTypesFromParameters(TypeVariable tvar, GenericTypeInfo typeInfo) {
		val supertypes = tvar.messageParameters
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
	
}
