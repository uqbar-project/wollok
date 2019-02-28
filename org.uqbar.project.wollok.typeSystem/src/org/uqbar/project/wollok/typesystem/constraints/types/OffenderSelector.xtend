package org.uqbar.project.wollok.typesystem.constraints.types

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState
import org.uqbar.project.wollok.typesystem.constraints.variables.ParameterTypeVariableOwner
import org.uqbar.project.wollok.typesystem.constraints.variables.ProgramElementTypeVariableOwner
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariableOwner
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfoInContext
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * When a type error is found because we found an incompatible subtype relationship between two type variables, 
 * I am the default strategy to select which of both variables to mark as errored. 
 */
class OffenderSelector {
	static val Logger log = Logger.getLogger(OffenderSelector)

	// ************************************************************************
	// ** Utilities
	// ************************************************************************
	def static handlingOffensesDo(TypeVariable subtype, TypeVariable supertype, ()=>ConcreteTypeState action) {
		try {
			action.apply()
		} catch(TypeSystemException offense) {
			handleOffense(subtype, supertype, offense)
			ConcreteTypeState.Error
		}
	}

	def static handlingOffensesDo(TypeVariable offender, ()=>ConcreteTypeState action) {
		try {
			action.apply()
		} catch(TypeSystemException offense) {
			offender.handleOffense(offense)
			ConcreteTypeState.Error
		}
	}

	def static handleOffense(TypeVariable subtype, TypeVariable supertype, TypeSystemException offense) {
		if(offense.variable === null) {
			val offender = selectOffenderVariable(subtype, supertype)
			offense.variable = offender
		}

		offense.variable.addError(offense)
	}

	def static handleOffense(TypeVariable offender, TypeSystemException offense) {
		if(offense.variable === null) offense.variable = offender
		offense.variable.addError(offense)
	}

	def static selectOffenderVariable(TypeVariable subtype, TypeVariable supertype) {
		if (subtype.owner.isCoreObject)
			supertype
		else if (supertype.owner.isCoreObject)
			subtype
		else {
			val offender = selectOffenderOwner(subtype.owner, supertype.owner)
			if (offender == subtype.owner) subtype else supertype	
		}
	}

	// ************************************************************************
	// ** Proper offender selection
	// ************************************************************************
	def static dispatch TypeVariableOwner selectOffenderOwner(ParameterTypeVariableOwner subtype,
		ParameterTypeVariableOwner supertype) {
		val offender = selectOffenderOwner(subtype.parent, supertype.parent)
		if(offender == subtype.parent) subtype else supertype
	}

	def static dispatch TypeVariableOwner selectOffenderOwner(ParameterTypeVariableOwner subtype,
		ProgramElementTypeVariableOwner supertype) {
		supertype
	}

	def static dispatch TypeVariableOwner selectOffenderOwner(ProgramElementTypeVariableOwner subtype,
		ParameterTypeVariableOwner supertype) {
		subtype
	}

	def static dispatch TypeVariableOwner selectOffenderOwner(ProgramElementTypeVariableOwner subtype,
		ProgramElementTypeVariableOwner supertype) {
		// TODO We are ignoring here other possible type variable owners, so this will be a problem soon.
		val offender = selectOffender(subtype.programElement, supertype.programElement)
		if(offender == subtype.programElement) subtype else supertype
	}

	def static dispatch selectOffender(EObject subtype, EObject supertype) {
		log.debug('''
			Error detected without a specific strategy to which element we should report the error:
				subtype=«subtype.debugInfoInContext» 
				supertype=«supertype.debugInfoInContext»
		''')
		subtype
	}

	/**
	 * If one of the variables has no associated node (remember Void parameter type ==> null node), 
	 * we have no alternative but marking the error in the other one.
	 */
	def static dispatch selectOffender(Void subtype, EObject supertype) { supertype }

	def static dispatch selectOffender(EObject subtype, Void supertype) { subtype }

	/**
	 * A variable is subtype of its references.
	 * Error should be marked when the variable is used.
	 */
	def static dispatch selectOffender(WReferenciable referenciable, WVariableReference reference) { reference }

	/** Referenciable appears as supertype when it is assigned, mark the error on the right hand side of the assignment */
	def static dispatch selectOffender(EObject reference, WReferenciable referenciable) { reference }

	/**
	 * A method declaration is subtype of the message sends which invoke that method. 
	 * Errors should go to the sender and not to the method.
	 */
	def static dispatch selectOffender(WMethodDeclaration returnType, EObject messageSend) { messageSend }

	/**
	 * A return expression fails to meet the return type of the method. 
	 */
	def static dispatch selectOffender(EObject returnExpression, WMethodDeclaration returnType) { returnExpression }
	
	/**
	 * A return (or final closure) expression fails to meet the return type of the closure. 
	 */
	def static dispatch selectOffender(EObject returnExpression, WBlockExpression blockReturnType) { returnExpression }

	/**
	 * A direct relationship between two parameters is due to a method override.
	 * (note inverse relationship: SUBclass method parameter has to be a SUPERtype of the overridden one.)
	 * We mark the errors in the subclass.
	 */
	def static dispatch selectOffender(WParameter superclass, WParameter subclass) {
		subclass
	}

}
