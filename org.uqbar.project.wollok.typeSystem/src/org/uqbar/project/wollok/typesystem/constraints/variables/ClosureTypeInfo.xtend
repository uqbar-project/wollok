package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import org.uqbar.project.wollok.typesystem.ClosureType
import org.uqbar.project.wollok.typesystem.WollokType
import org.eclipse.xtend.lib.annotations.Accessors

class ClosureTypeInfo extends TypeInfo {
	@Accessors(PUBLIC_GETTER)
	List<ITypeVariable> parameters

	@Accessors(PUBLIC_GETTER)
	ITypeVariable returnType

	new(List<ITypeVariable> parameters, ITypeVariable returnType) {
		this.parameters = parameters
		this.returnType = returnType
	}

	// ************************************************************************
	// ** Queries
	// ************************************************************************
	override getType(TypeVariable user) {
		return new ClosureType(
			parameters.map[(it as TypeVariable).type], 
			(returnType as TypeVariable).type
		)
	}

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	override beSealed() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override addMinType(WollokType type) {
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
	
	
	// ************************************************************************
	// ** Utilities
	// ************************************************************************

	/**
	 * type parameter for closure types
	 */
	public static val RETURN = "return"
}
