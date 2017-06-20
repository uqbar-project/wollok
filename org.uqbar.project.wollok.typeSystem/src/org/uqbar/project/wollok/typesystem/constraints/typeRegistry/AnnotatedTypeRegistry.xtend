package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.Map
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.declarations.TypeDeclarationTarget
import org.uqbar.project.wollok.typesystem.declarations.WollokCoreTypeDeclarations
import org.uqbar.project.wollok.wollokDsl.WClass

import static extension org.uqbar.project.wollok.typesystem.declarations.TypeDeclarations.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo.ELEMENT

class AnnotatedTypeRegistry implements TypeDeclarationTarget {
	TypeVariablesRegistry registry
	Map<String, Map<String, AnnotatedMethodTypeInfo>> methodTypeInfo = newHashMap

	new(TypeVariablesRegistry registry) {
		this.registry = registry
		addTypeDeclarations(WollokCoreTypeDeclarations)
	}

	override addTypeDeclaration(String typeName, String selector, String[] paramTypeNames, String returnTypeName) {
		var info = methodTypeInfo.get(typeName)
		if (info == null) methodTypeInfo.put(typeName, info = newHashMap)
		info.put(selector,
			new AnnotatedMethodTypeInfo(paramTypeNames.map[asTypeAnnotation], returnTypeName.asTypeAnnotation))
	}

	def asTypeAnnotation(String typeName) {
		val annotation = if (typeName == ELEMENT)
				new ClassParameterTypeAnnotation(typeName)
			else
				new SimpleTypeAnnotation(typeName)

		annotation.registry = registry
		annotation
	}

	def get(ConcreteType type, String selector) {
		methodTypeInfo.get(type.name)?.get(selector)
	}

	def get(WClass container, String selector) {
		methodTypeInfo.get(container.name)?.get(selector)
	}

}
