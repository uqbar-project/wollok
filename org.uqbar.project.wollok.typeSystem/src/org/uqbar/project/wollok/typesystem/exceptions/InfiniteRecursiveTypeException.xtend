package org.uqbar.project.wollok.typesystem.exceptions

import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

class InfiniteRecursiveTypeException extends TypeSystemException {
	
	new(TypeVariable variable) {
		super(variable)
	}
	
	override getMessage() { Messages.TypeSystemException_INFINITE_RECURSIVE_TYPE }
}