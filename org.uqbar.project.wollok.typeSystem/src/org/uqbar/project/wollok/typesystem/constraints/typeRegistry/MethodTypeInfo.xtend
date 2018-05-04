package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.List
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.lookupMethod

class MethodTypeProvider {
	val TypeVariablesRegistry registry
	
	new(TypeVariablesRegistry registry) {
		this.registry = registry	
	}
	
	def dispatch forType(ConcreteType type, String selector, List<TypeVariable> arguments) {
		val method = type.lookupMethod(selector, arguments)
		new MethodTypeInfo(registry, method)
	}

	def dispatch forType(WollokType type, String selector, List<TypeVariable> arguments) {
		throw new UnsupportedOperationException('''Can't extract methodTypeInfo for methods of «type»''')
	}

	def forClass(WClass container, String selector, List<?> arguments) {
		new MethodTypeInfo(registry, container.lookupMethod(selector, arguments, true))
	}
}

class MethodTypeInfo {
	WMethodDeclaration method
	extension TypeVariablesRegistry registry

	new(TypeVariablesRegistry registry, WMethodDeclaration method) {
		if (method === null)
			throw new IllegalArgumentException('''Tried to create a «class.simpleName» with a null method''')
		this.registry = registry
		this.method = method
	}

	def returnType() {
		method.tvarOrParam
	}

	def parameters() {
		method.parameters.map[tvarOrParam]
	}
}

