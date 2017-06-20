package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import org.uqbar.project.wollok.typesystem.ClosureType
import org.uqbar.project.wollok.typesystem.WollokType

class ClosureTypeInfo extends TypeInfo {

	List<TypeVariable> parameters

	TypeVariable returnType

	new(List<TypeVariable> parameters, TypeVariable returnType) {
		this.parameters = parameters
		this.returnType = returnType
	}

	// ************************************************************************
	// ** Queries
	// ************************************************************************
	override getType(TypeVariable user) {
		return new ClosureType(parameters.map[type], returnType.type)
	}

	override hasErrors() {
		parameters.exists[hasErrors] || returnType.hasErrors
	}

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	override beSealed() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override addMinimalType(WollokType type) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	// ************************************************************************
	// ** Misc
	// ************************************************************************

	override fullDescription() '''
		parameters: «parameters»
		returnType: «returnType»
	'''
}
