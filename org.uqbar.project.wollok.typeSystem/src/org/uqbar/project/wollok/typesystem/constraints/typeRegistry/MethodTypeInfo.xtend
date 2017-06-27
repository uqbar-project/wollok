package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

interface TypeAnnotation {
}

class SimpleTypeAnnotation<T extends WollokType> implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	T type

	new(T type) {
		this.type = type
	}
}

class ClassParameterTypeAnnotation implements TypeAnnotation {
	@Accessors
	String paramName

	new(String paramName) {
		this.paramName = paramName
	}
}

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
