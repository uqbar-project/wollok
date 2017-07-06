package org.uqbar.project.wollok.typesystem.exceptions

import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.WollokType

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.WollokTypeSystemPrettyPrinter.*

class RejectedMinTypeException extends TypeSystemException {

	TypeVariable variable

	WollokType type

	new(TypeVariable variable, WollokType type) {
		this.variable = variable
		this.type = type
	}

	override getMessage() {
		'''expected <<«variable.expectedType»>> but found <<«variable.foundType»>>'''
	}
}
