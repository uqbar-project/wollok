package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.List
import java.util.Map
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.constraints.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.declarations.TypeDeclarationTarget
import org.uqbar.project.wollok.typesystem.declarations.WollokCoreTypeDeclarations
import org.uqbar.project.wollok.wollokDsl.WClass

import static extension org.uqbar.project.wollok.typesystem.declarations.TypeDeclarations.*

class AnnotatedTypeRegistry implements TypeDeclarationTarget {
	TypeVariablesRegistry registry
	Map<String, Map<String, AnnotatedMethodTypeInfo>> methodTypeInfo = newHashMap
	
	new(TypeVariablesRegistry registry) {
		this.registry = registry
		addTypeDeclarations(WollokCoreTypeDeclarations)
	}

	override addTypeDeclaration(String typeName, String selector, List<String> paramTypeNames, String returnTypeName) {
		var info = methodTypeInfo.get(typeName)
		if (info == null) methodTypeInfo.put(typeName, info = newHashMap)
		info.put(selector, new AnnotatedMethodTypeInfo(registry, paramTypeNames, returnTypeName))
	}
	
	def get(ConcreteType type, String selector) {
		methodTypeInfo.get(type.name)?.get(selector)
	}

	def get(WClass container, String selector) {
		methodTypeInfo.get(container.name)?.get(selector)
	}
	
}