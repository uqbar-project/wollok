package org.uqbar.project.wollok.typesystem.constraints.typeRegistry

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.annotations.ClassParameterTypeAnnotation
import org.uqbar.project.wollok.typesystem.annotations.GenericTypeInstanceAnnotation
import org.uqbar.project.wollok.typesystem.annotations.SimpleTypeAnnotation
import org.uqbar.project.wollok.typesystem.annotations.TypeAnnotation
import org.uqbar.project.wollok.typesystem.annotations.TypeDeclarationTarget
import org.uqbar.project.wollok.typesystem.annotations.VoidTypeAnnotation
import org.uqbar.project.wollok.typesystem.constraints.variables.GeneralTypeVariableSchema
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.ParameterTypeVariableOwner
import org.uqbar.project.wollok.typesystem.constraints.variables.ProgramElementTypeVariableOwner
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariableOwner
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

class AnnotatedTypeRegistry implements TypeDeclarationTarget {
	extension TypeVariablesRegistry registry
	EObject context

	new(TypeVariablesRegistry registry, EObject context) {
		this.registry = registry
		this.context = context
	}

	override addMethodTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation[] paramTypes, TypeAnnotation returnType) {
		val method = receiver.lookupMethod(selector, paramTypes)
		method.parameters.biForEach(paramTypes)[parameter, type|parameter.asOwner.beSealed(type)]
		method.asOwner.beSealed(returnType)
	}

	override addConstructorTypeDeclaration(ClassBasedWollokType receiver, TypeAnnotation[] paramTypes) {
		var constructor = receiver.getConstructor(paramTypes)
		constructor.parameters.biForEach(paramTypes)[parameter, type|parameter.asOwner.beSealed(type)]
	}
	
	override addVariableTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation annotation) {
		var declaration = receiver.container.getVariableDeclaration(selector)
		declaration => [
			asOwner.beSealed(annotation)
			variable.asOwner.beSealed(annotation)
		]
	}
	
	def dispatch ITypeVariable beSealed(TypeVariableOwner owner, SimpleTypeAnnotation<?> annotation) {
		newTypeVariable(owner) => [beSealed(annotation.type)]
	}

	def dispatch ITypeVariable beSealed(TypeVariableOwner owner, ClassParameterTypeAnnotation annotation) {
		newClassParameterVar(owner, annotation.type, annotation.paramName)
	}
	
	def dispatch ITypeVariable beSealed(TypeVariableOwner owner, VoidTypeAnnotation annotation) {
		newTypeVariable(owner) => [beVoid]
	}

	def dispatch ITypeVariable beSealed(TypeVariableOwner owner, GenericTypeInstanceAnnotation it) {
		register(new GeneralTypeVariableSchema(owner,   
			type.schema(newHashMap(typeParameters.entrySet.map[key -> 
				new ParameterTypeVariableOwner(owner, key).beSealed(value)
			]))))
	}
	
	def asOwner(EObject programElement) {
		new ProgramElementTypeVariableOwner(programElement)
	}
}
