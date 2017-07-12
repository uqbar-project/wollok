package org.uqbar.project.wollok.typesystem.exceptions

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.WollokTypeSystemPrettyPrinter.*

class RejectedMinTypeException extends TypeSystemException {
	@Accessors
	TypeVariable variable

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
		'''expected <<«variable.expectedType»>> but found <<«variable.foundType»>>'''
	}
}
