package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.AnalysisResultReporter
import org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo

import static org.uqbar.project.wollok.typesystem.constraints.types.OffenderSelector.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.AnalysisResultReporter.*

abstract class PropagateMinimalTypes extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch analiseVariable(TypeVariable tvar, GenericTypeInfo typeInfo) {
		val supertypes = tvar.allSupertypes
		typeInfo.minTypes.statesWithValueDo(targetMinTypeState, tvar) [
			tvar.propagateMinType(type, supertypes, it)
		]
	}

	def dispatch analiseVariable(TypeVariable user, VoidTypeInfo typeInfo) {
		typeInfo.propagationStatus.statesWithValueDo(targetMinTypeState, user) [
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

	protected def boolean propagateMinType(TypeVariable origin, WollokType type, Iterable<TypeVariable> supertypes,
		AnalysisResultReporter<WollokType> reporter) {
		supertypes.evaluate [ supertype |
			val newState = propagateMinType(origin, supertype, type)
			reporter.newState(newState)
			(newState != Ready && newState != Postponed) => [
				if (it) {
					log.debug('''  Propagated min(«type») from: «origin» to «supertype» => «newState»''')
					changed = true
				}
			]
		]
	}

	def propagateMinType(TypeVariable origin, TypeVariable destination, WollokType type) {
		if(!origin.shouldPropagateMinTypes(destination)) return Postponed
		handlingOffensesDo(origin, destination) [
			destination.addMinType(type)
		]
	}

	def boolean evaluate(Iterable<TypeVariable> variables, (TypeVariable)=>boolean action) {
		variables.fold(false)[hasChanges, variable|action.apply(variable) || hasChanges]
	}

	def abstract boolean shouldPropagateMinTypes(TypeVariable origin, TypeVariable destination)

	def abstract ConcreteTypeState targetMinTypeState()
}

class PropagatePendingMinimalTypes extends PropagateMinimalTypes {

	override shouldPropagateMinTypes(TypeVariable origin, TypeVariable destination) {
		!destination.owner.isParameter
	}

	override targetMinTypeState() { Pending }

}

class PropagatePostponedMinimalTypes extends PropagateMinimalTypes {

	override shouldPropagateMinTypes(TypeVariable origin, TypeVariable destination) {
		destination.owner.isParameter
	}

	override targetMinTypeState() { Postponed }
}
