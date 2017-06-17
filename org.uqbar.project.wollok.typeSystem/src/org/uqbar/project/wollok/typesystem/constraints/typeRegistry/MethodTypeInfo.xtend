package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.List
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

interface MethodTypeInfo {
	def TypeVariable returnType()
	def List<TypeVariable> parameters()
}

class AnnotatedMethodTypeInfo implements MethodTypeInfo {
	TypeVariablesRegistry registry
	String returnType
	String[] parameterTypes

	new(TypeVariablesRegistry registry, List<String> parameterTypes, String returnType) {
		this.registry = registry
		this.parameterTypes = parameterTypes
		this.returnType = returnType
	}

	override returnType() {
		registry.newSyntheticVar(returnType)
	}

	override parameters() {
		parameterTypes.map[registry.newSyntheticVar(it)]
	}
}

class MethodTypeInfoImpl implements MethodTypeInfo {
	WMethodDeclaration method
	extension TypeVariablesRegistry registry

	new(TypeVariablesRegistry registry, WMethodDeclaration method) {
		this.registry = registry
		this.method = method
	}

	override returnType() {
		method.tvar
	}

	override parameters() {
		method.parameters.map[tvar]
	}
}
