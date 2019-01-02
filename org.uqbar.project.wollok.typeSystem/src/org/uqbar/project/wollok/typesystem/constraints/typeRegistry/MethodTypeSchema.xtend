package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

/**
 * Type schemas are different from types in that they can have type variables inside.
 * E.g. method first in type List<E> has type ()=>E
 */
abstract class MethodTypeSchema {
	TypeVariablesRegistry registry

	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def ITypeVariable returnType()

	def Iterable<ITypeVariable> parameters()

	def tvarOrParam(EObject object) {
		registry.tvarOrParam(object)
	}

	def instanceFor(ConcreteType type, MessageSend message) {
		instance[instanceFor(type, message)]
	}

	def instance((ITypeVariable)=>TypeVariable variableResolver) {
		new MethodTypeInfo(parameters.map(variableResolver), variableResolver.apply(returnType))
	}
}

class RegularMethodTypeSchema extends MethodTypeSchema {
	WMethodDeclaration method

	new(TypeVariablesRegistry registry, WMethodDeclaration method) {
		super(registry)
		this.method = method
	}

	override returnType() {
		method.tvarOrParam
	}

	override parameters() {
		method.parameters.map[tvarOrParam]
	}
}

class PropertyGetterTypeInfo extends MethodTypeSchema {
	WVariableDeclaration declaration

	new(TypeVariablesRegistry registry, WVariableDeclaration declaration) {
		super(registry)
		this.declaration = declaration
	}

	override returnType() {
		declaration.variable.tvarOrParam
	}

	override parameters() {
		#[]
	}

}

class PropertySetterTypeInfo extends MethodTypeSchema {

	WVariableDeclaration declaration

	new(TypeVariablesRegistry registry, WVariableDeclaration declaration) {
		super(registry)
		this.declaration = declaration
	}

	override returnType() {
		// This is a hack because the declaration is void and the setter also is, but they are different things.
		declaration.tvarOrParam
	}

	override parameters() {
		#[declaration.variable.tvarOrParam]
	}

}
