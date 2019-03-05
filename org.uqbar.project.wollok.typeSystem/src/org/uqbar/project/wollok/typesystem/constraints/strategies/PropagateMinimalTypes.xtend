package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.ParameterTypeVariableOwner
import org.uqbar.project.wollok.typesystem.constraints.variables.ProgramElementTypeVariableOwner
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo
import org.uqbar.project.wollok.wollokDsl.WParameter

import static org.uqbar.project.wollok.typesystem.constraints.types.OffenderSelector.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.AnalysisResultReporter.*

class PropagateMinimalTypes extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch analiseVariable(TypeVariable tvar, GenericTypeInfo typeInfo) {
		val supertypes = tvar.allSupertypes
		typeInfo.minTypes.pendingStatesDo(tvar) [
			tvar.propagateMinType(type, supertypes)
			ready
		]
	}

	def dispatch analiseVariable(TypeVariable user, VoidTypeInfo typeInfo) {
		typeInfo.propagationStatus.pendingStatesDo(user) [
			val newState = handlingOffensesDo(user, type) [
				type.beVoid
				ready()
			]

			(newState != Ready) => [ hasChanged |
				if (hasChanged) {
					log.debug('''  Propagating void from «user» to «type» => «newState»''')
					changed = true
				}
			]
		]
	}

	protected def boolean propagateMinType(TypeVariable origin, WollokType type, Iterable<TypeVariable> supertypes) {
		supertypes.evaluate [ supertype |
			val newState = propagateMinType(origin, supertype, type)
			(newState != Ready) => [
				if (it) {
					log.debug('''  Propagated min(«type») from: «origin» to «supertype» => «newState»''')
					changed = true
				}
			]
		]
	}

	def propagateMinType(TypeVariable origin, TypeVariable destination, WollokType type) {
		val shouldPropagateMinTypes = origin.shouldPropagateMinTypesTo(destination)
		if (!shouldPropagateMinTypes) return Cancel
		handlingOffensesDo(origin, destination) [
			destination.addMinType(type)
		]
	}

	def boolean evaluate(Iterable<TypeVariable> variables, (TypeVariable)=>boolean action) {
		variables.fold(false)[hasChanges, variable|action.apply(variable) || hasChanges]
	}
	
	def shouldPropagateMinTypesTo(TypeVariable origin, TypeVariable destination) {
		//TODO: think better
		!destination.owner.isMethodParameter
	}
	
	def dispatch isMethodParameter(ParameterTypeVariableOwner owner) {
		false
	}
	
	def dispatch isMethodParameter(ProgramElementTypeVariableOwner owner) {
		(owner.programElement instanceof WParameter) && owner.programElement.declaringMethod !== null 
	}
}
