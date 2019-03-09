package org.uqbar.project.wollok.typesystem.exceptions

import java.util.Set
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.typesystem.Constants
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.WollokTypeSystemPrettyPrinter.*

class RejectedMinTypeException extends TypeSystemException {
	WollokType type
	Set<WollokType> expectedTypes = newHashSet
	
	new(TypeVariable variable, WollokType type) {
		super(variable)
		this.type = type
	}

	new(TypeVariable variable, WollokType type, Set<WollokType> expectedTypes) {
		this(variable, type)
		if (expectedTypes !== null)
			this.expectedTypes = expectedTypes
	}

	/**
	 * This constructor allows for a later assignment of the offending variable, 
	 * for cases in which we want a more sophisticated algorithm for determining it.
	 */
	new(WollokType type) {
		this.type = type
	}

	override getMessage() {
		// Support null `variable`. While it should not happen and means
		// a program error, it is not nice to throw a NPE inside the toString
		// of a previous exception.
		NLS.bind(Messages.TypeSystemException_REJECTED_MIN_TYPE_MESSAGE, expectedType, type)
	}
	
	def expectedType() {
		if (!expectedTypes.isEmpty) return expectedTypes.join("|")
		if (variable !== null) variable.expectedType else Constants.UNKNOWN
	}
	
	override relatedToType(WollokType typeRelated) {
		type == typeRelated
	}
	
}