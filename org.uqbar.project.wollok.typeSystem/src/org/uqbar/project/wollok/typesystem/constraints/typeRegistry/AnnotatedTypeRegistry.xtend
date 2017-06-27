package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.declarations.TypeDeclarationTarget
import org.uqbar.project.wollok.wollokDsl.WClass

class AnnotatedTypeRegistry implements TypeDeclarationTarget {
	TypeVariablesRegistry registry
	EObject context
	Map<String, Map<String, AnnotatedMethodTypeInfo>> methodTypeInfo = newHashMap

	new(TypeVariablesRegistry registry, EObject context) {
		this.registry = registry
		this.context = context
	}

	override addTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation[] paramTypes, TypeAnnotation returnType) {
		var info = methodTypeInfo.get(receiver.name)
		if (info == null) methodTypeInfo.put(receiver.name, info = newHashMap)
		
		paramTypes.forEach[it.registry = registry]
		returnType.registry = registry
		
		info.put(selector, new AnnotatedMethodTypeInfo(paramTypes, returnType))
	}

	def get(ConcreteType type, String selector) {
		methodTypeInfo.get(type.name)?.get(selector)
	}

	def get(WClass container, String selector) {
		methodTypeInfo.get(container.name)?.get(selector)
	}

}
