package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.exceptions.RejectedMinTypeException
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo

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
		catch (RejectedMinTypeException exception) {
			val offender = selectOffender(origin.owner, destination.owner)
			val variable = if (offender == origin.owner) origin else destination
			variable.addError(exception)
			exception.variable = variable
			Error
		}
	}
	
	def boolean evaluate(Iterable<TypeVariable> variables, (TypeVariable)=>boolean action) {
		variables.fold(false)[hasChanges, variable | action.apply(variable) || hasChanges ]
	}
	
	def dispatch selectOffender(EObject origin, EObject destination) {
		log.debug('''	Min type detected without a specific offender detection strategy:
			origin=«origin.debugInfo» 
			destination=«destination.debugInfo»''') 
		origin
	}

	def dispatch selectOffender(WVariable origin, WVariableReference destination) {
		// Error report goes to variable usage. 
		destination
	}
}
