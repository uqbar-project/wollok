package org.uqbar.project.wollok.typesystem.constraints.types

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.exceptions.RejectedMinTypeException
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo

/**
 * When a type error is found because we found an incompatible subtype relationship between two type variables, 
 * I am the default strategy to select which of both variables to mark as errored. 
 */
class OffenderSelector {
	static val Logger log = Logger.getLogger(OffenderSelector)

	// ************************************************************************
	// ** Utilities
	// ************************************************************************

	def static handleOffense(TypeVariable subtype, TypeVariable supertype, RejectedMinTypeException offense) {
		val offender = selectOffenderVariable(subtype, supertype)
		offender.addError(offense)
		offense.variable = offender
	}

	def static selectOffenderVariable(TypeVariable subtype, TypeVariable supertype) {
		val offender = selectOffender(subtype.owner, supertype.owner)
		if(offender == subtype.owner) subtype else supertype
	}

	// ************************************************************************
	// ** Proper offender selection
	// ************************************************************************

	def static dispatch selectOffender(EObject subtype, EObject supertype) {
		log.warn('''	Min type detected without a specific offender detection strategy:
			origin=«subtype.debugInfo» 
			destination=«supertype.debugInfo»''')
		subtype
	}

	def static dispatch selectOffender(WVariable variable, WVariableReference reference) {
		// Error report goes to variable usage. 
		reference
	}

}
