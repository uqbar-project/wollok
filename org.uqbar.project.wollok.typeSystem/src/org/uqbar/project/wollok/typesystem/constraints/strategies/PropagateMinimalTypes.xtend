package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo

import static org.uqbar.project.wollok.typesystem.constraints.types.OffenderSelector.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

class PropagateMinimalTypes extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	def dispatch analiseVariable(TypeVariable tvar, SimpleTypeInfo typeInfo) {
		val supertypes = tvar.allSupertypes
		typeInfo.minTypesDo(tvar) [
			if (state == Pending) {
				tvar.propagateMinType(type, supertypes)
				ready
			}
		]
	}

	def dispatch analiseVariable(TypeVariable user, VoidTypeInfo typeInfo) {
		user.supertypes.forEach [ supertype |
			handlingOffensesDo(user, supertype)[
				supertype.beVoid
				Ready
			] => [ newState |
				log.debug('''  Propagating void from «user» to «supertype» => «newState»''')
			]
		]
	}

	protected def boolean propagateMinType(TypeVariable origin, WollokType type, Iterable<TypeVariable> supertypes) {
		supertypes.evaluate [ supertype |
			log.trace('''  About to propagate min(«type») from: «origin» to «supertype»''')
			val newState = propagateMinType(origin, supertype, type)
			(newState != Ready) => [
				if(it) {
					log.debug('''  Propagating min(«type») from: «origin» to «supertype» => «newState»''')
					changed = true
				}
			]
		]
	}

	def propagateMinType(TypeVariable origin, TypeVariable destination, WollokType type) {
		handlingOffensesDo(origin, destination)[
			destination.addMinType(type)
		]
	}

	def boolean evaluate(Iterable<TypeVariable> variables, (TypeVariable)=>boolean action) {
		variables.fold(false)[hasChanges, variable|action.apply(variable) || hasChanges]
	}

	def handlingOffensesDo(TypeVariable subtype, TypeVariable supertype, ()=>ConcreteTypeState action) {
		try {
			action.apply()
		} catch (TypeSystemException offense) {
			handleOffense(subtype, supertype, offense)
			Error
		}
	}
}
