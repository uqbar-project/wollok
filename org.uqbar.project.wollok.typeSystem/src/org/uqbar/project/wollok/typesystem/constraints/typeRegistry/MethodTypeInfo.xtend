package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

class MethodTypeInfo {
	WMethodDeclaration method
	extension TypeVariablesRegistry registry

	new(TypeVariablesRegistry registry, WMethodDeclaration method) {
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
