package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map

class GenericTypeInfo extends SimpleTypeInfo {
	Map<String, TypeVariable> params
	
	new(Map<String, TypeVariable> params) {
		this.params = params
	}

	// ************************************************************************
	// ** Utilities
	// ************************************************************************

	/**
	 * Default type parameter for collection types
	 */
	public static val ELEMENT = "element"

	static def TypeVariable element(TypeVariable user) {
		(user.typeInfo as GenericTypeInfo).params.get(ELEMENT)
	}

}
