package org.uqbar.project.wollok.typesystem.constraints.types

import java.util.List
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInstance
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.exceptions.InfiniteRecursiveTypeException

class RecursiveTypeValidator {
	def static dispatch void validateRecursiveType(TypeInfo t1, TypeInfo t2) {
		t1.validateRecursiveType(t2.users)
		t2.validateRecursiveType(t1.users)		
	}

	def static dispatch void validateRecursiveType(TypeInfo typeInfo, List<TypeVariable> users) {}
	def static dispatch void validateRecursiveType(GenericTypeInfo typeInfo, List<TypeVariable> users) {
		typeInfo.maximalConcreteTypes?.forEach[it.doValidateRecursiveType(users)]
		typeInfo.validMinTypes.forEach[it.doValidateRecursiveType(users)]
	}

	def static dispatch void doValidateRecursiveType(WollokType it, List<TypeVariable> users) {}
	def static dispatch void doValidateRecursiveType(GenericTypeInstance it, List<TypeVariable> users) {
		typeParameters.values.forEach [ param |
			if(users.contains(param)) throw new InfiniteRecursiveTypeException(param)
		]
	}
}
