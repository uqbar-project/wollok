package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors

class GenericTypeInfo extends SimpleTypeInfo {
	@Accessors
	Map<String, TypeVariable> params
	
	new(Map<String, TypeVariable> params) {
		this.params = params
	}

	def param(String paramName) {
		params.get(paramName)
	}

	// ************************************************************************
	// ** Utilities
	// ************************************************************************

	/**
	 * Default type parameter for collection types
	 */
	public static val ELEMENT = "element"
	public static val KEY = "key"
	public static val VALUE = "value"

	static def TypeVariable element(TypeVariable user) {
		(user.typeInfo as GenericTypeInfo).param(ELEMENT)
	}

}
