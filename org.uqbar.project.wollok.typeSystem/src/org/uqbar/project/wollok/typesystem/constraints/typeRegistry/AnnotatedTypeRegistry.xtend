package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.annotations.ClassParameterTypeAnnotation
import org.uqbar.project.wollok.typesystem.annotations.ClosureTypeAnnotation
import org.uqbar.project.wollok.typesystem.annotations.SimpleTypeAnnotation
import org.uqbar.project.wollok.typesystem.annotations.TypeAnnotation
import org.uqbar.project.wollok.typesystem.annotations.TypeDeclarationTarget
import org.uqbar.project.wollok.typesystem.annotations.VoidTypeAnnotation
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry

import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

class AnnotatedTypeRegistry implements TypeDeclarationTarget {
	TypeVariablesRegistry registry
	EObject context

	new(TypeVariablesRegistry registry, EObject context) {
		this.registry = registry
		this.context = context
	}

	override addMethodTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation[] paramTypes, TypeAnnotation returnType) {
		val method = receiver.lookupMethod(selector, paramTypes)
		method.parameters.biForEach(paramTypes)[parameter, type|parameter.beSealed(type)]
		method.beSealed(returnType)
	}

	override addConstructorTypeDeclaration(ClassBasedWollokType receiver, TypeAnnotation[] paramTypes) {
		var constructor = receiver.getConstructor(paramTypes)
		constructor.parameters.biForEach(paramTypes)[parameter, type|parameter.beSealed(type)]
	}
	
	def dispatch ITypeVariable beSealed(EObject object, SimpleTypeAnnotation<?> annotation) {
		registry.newSealed(object, annotation.type)
	}

	def dispatch ITypeVariable beSealed(EObject object, ClassParameterTypeAnnotation annotation) {
		registry.newClassParameterVar(object, annotation.type, annotation.paramName)
	}
	
	def dispatch ITypeVariable beSealed(EObject object, VoidTypeAnnotation annotation) {
		registry.newVoid(object)
	}

	def dispatch ITypeVariable beSealed(EObject object, ClosureTypeAnnotation it) {
		registry.newClosure(
			object,
			parameters.map[param | beSealed(null, param)],
			beSealed(null, returnType)
		)
	}
}
