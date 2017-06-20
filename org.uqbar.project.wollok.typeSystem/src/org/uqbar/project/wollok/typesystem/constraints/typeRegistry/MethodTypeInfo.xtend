package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

interface MethodTypeInfo {
	def ITypeVariable returnType()

	def List<ITypeVariable> parameters()
}

class AnnotatedMethodTypeInfo implements MethodTypeInfo {
	TypeAnnotation returnType
	TypeAnnotation[] parameterTypes

	new(TypeAnnotation[] parameterTypes, TypeAnnotation returnType) {
		this.parameterTypes = parameterTypes
		this.returnType = returnType
	}

	override returnType() {
		returnType.asTypeVariable
	}

	override parameters() {
		parameterTypes.map[asTypeVariable]
	}
}

abstract class TypeAnnotation {
	@Accessors
	TypeVariablesRegistry registry

	def ITypeVariable asTypeVariable()
}

class SimpleTypeAnnotation extends TypeAnnotation {
	String className

	new(String className) {
		this.className = className
	}

	override asTypeVariable() {
		registry.newSyntheticVar(className)
	}
}

class ClassParameterTypeAnnotation extends TypeAnnotation {
	String paramName

	new(String paramName) {
		this.paramName = paramName
	}

	override asTypeVariable() {
		registry.newClassParameterVar(paramName)
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
