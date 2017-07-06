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

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	override beSealed() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override addMinType(WollokType type, TypeVariable origin) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable origin) {
		throw new UnsupportedOperationException('''
			Tring to assign a maxType to a clousure
				maxTypes: «maxTypes»
				origin: «origin»
		''')
	}

	// ************************************************************************
	// ** Misc
	// ************************************************************************

	override fullDescription() '''
		parameters: «parameters»
		returnType: «returnType»
	'''
}
