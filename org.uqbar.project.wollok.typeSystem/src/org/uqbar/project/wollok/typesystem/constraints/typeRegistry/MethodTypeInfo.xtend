package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInstance
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.ClosureType.*

/**
 * Type info is a concrete type that can not have type variables.
 * E.g. method filter in the context of a List<Number> has type List<Number>
 */
class MethodTypeInfo {
	@Accessors
	val List<TypeVariable> parameters

	@Accessors
	val TypeVariable returnType

	new(Iterable<TypeVariable> parameters, TypeVariable returnType) {
		this.parameters = parameters.toList
		this.returnType = returnType
	}

	static def MethodTypeInfo forClosureApply(GenericTypeInstance closureType) {
		new MethodTypeInfo(closureType.paramTypeVariables, closureType.returnTypeVariable)
	}

	override toString() '''MethodType [«parameters.join(", ")»]=>«returnType»'''	
}
