package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.declarations.TypeDeclarationTarget
import org.uqbar.project.wollok.wollokDsl.WClass

import static org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo.ELEMENT

class AnnotatedTypeRegistry implements TypeDeclarationTarget {
	TypeVariablesRegistry registry
	EObject context
	Map<String, Map<String, AnnotatedMethodTypeInfo>> methodTypeInfo = newHashMap

	new(TypeVariablesRegistry registry, EObject context) {
		this.registry = registry
		this.context = context
	}

	override addTypeDeclaration(ConcreteType receiver, String selector, String[] paramTypeNames, String returnTypeName) {
		var info = methodTypeInfo.get(receiver.name)
		if (info == null) methodTypeInfo.put(receiver.name, info = newHashMap)
		info.put(selector,
			new AnnotatedMethodTypeInfo(paramTypeNames.map[asTypeAnnotation], returnTypeName.asTypeAnnotation))
	}

	def asTypeAnnotation(String typeName) {
		val annotation = if (typeName == ELEMENT)
				new ClassParameterTypeAnnotation(typeName)
			else
				new SimpleTypeAnnotation(typeName)

		annotation.registry = registry
		annotation.context = context
		annotation
	}

	def get(ConcreteType type, String selector) {
		methodTypeInfo.get(type.name)?.get(selector)
	}

	def get(WClass container, String selector) {
		methodTypeInfo.get(container.name)?.get(selector)
	}

}
