package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.exceptions.RejectedMinTypeException

import static org.uqbar.project.wollok.typesystem.constraints.types.OffenderSelector.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

class PropagateMinimalTypes extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)
	
	def dispatch analiseVariable(TypeVariable tvar, SimpleTypeInfo typeInfo) {
		val supertypes = tvar.allSupertypes
		typeInfo.minTypesDo(tvar)[
			if (state == Pending) {
//				val localChanged = 
				tvar.propagateMinType(type, supertypes)
//				if (!localChanged)
//					println('''	Propagating min(«type») from: «tvar» to nowhere => «Ready»''')

				ready
				changed = true
			}
		]
	}

	protected def boolean propagateMinType(TypeVariable origin, WollokType type, Iterable<TypeVariable> supertypes) {
		supertypes.evaluate[ supertype |
			val newState = propagateMinType(origin, supertype, type)
			(newState != Ready)
				=> [ if (it) log.debug('''	Propagating min(«type») from: «origin» to «supertype» => «newState»''')]
		]
	}

	def propagateMinType(TypeVariable origin, TypeVariable destination, WollokType type) {
		try {
			destination.addMinType(type)
		}
		catch (RejectedMinTypeException offense) {
			handleOffense(origin, destination, offense)
			Error
		}
	}

	def boolean evaluate(Iterable<TypeVariable> variables, (TypeVariable)=>boolean action) {
		variables.fold(false)[hasChanges, variable | action.apply(variable) || hasChanges ]
	}
}
