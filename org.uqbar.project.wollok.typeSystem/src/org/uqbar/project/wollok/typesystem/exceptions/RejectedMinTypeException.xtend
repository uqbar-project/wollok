package org.uqbar.project.wollok.typesystem.exceptions

import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.WollokTypeSystemPrettyPrinter.*

class RejectedMinTypeException extends TypeSystemException {
	WollokType type

	new(TypeVariable variable, WollokType type) {
		this.variable = variable
		this.type = type
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
		'''expected <<«if (variable !== null) variable.expectedType else "unknown"»>> but found <<«type»>>'''
	}
}