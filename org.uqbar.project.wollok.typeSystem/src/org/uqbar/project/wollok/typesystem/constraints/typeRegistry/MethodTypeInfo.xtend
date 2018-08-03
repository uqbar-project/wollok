package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInstance
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry

import static extension org.uqbar.project.wollok.typesystem.ClosureType.*

/**
 * Type info is a concrete type that can not have type variables.
 * E.g. method filter in the context of a List<Number> has type List<Number>
 */
interface MethodTypeInfo {
	def TypeVariable returnType()

	def Iterable<TypeVariable> parameters()
}

class SchemaBasedMethodTypeInfo implements MethodTypeInfo {
	
	MethodTypeSchema schema
	
	(ITypeVariable)=>TypeVariable variableResolver
	
	new(MethodTypeSchema schema, (ITypeVariable) => TypeVariable variableResolver) {
		this.schema = schema
		this.variableResolver = variableResolver
	}
	
	override TypeVariable returnType() {
		variableResolver.apply(schema.returnType)
		
	}

	override Iterable<TypeVariable> parameters() {
		schema.parameters.map(variableResolver)
	}
	
}

class ClosureApplyTypeInfo implements MethodTypeInfo {

	GenericTypeInstance typeInstance

	new(TypeVariablesRegistry registry, GenericTypeInstance typeInstance) {
		this.typeInstance = typeInstance
	}

	override returnType() {
		typeInstance.returnTypeVariable
	}

	override parameters() {
		typeInstance.paramTypeVariables
	}
}
