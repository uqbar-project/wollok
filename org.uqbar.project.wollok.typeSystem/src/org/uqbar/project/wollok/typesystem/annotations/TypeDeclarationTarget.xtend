package org.uqbar.project.wollok.typesystem.annotations

import org.uqbar.project.wollok.typesystem.ClassInstanceType
import org.uqbar.project.wollok.typesystem.ConcreteType

interface TypeDeclarationTarget {
	def void addMethodTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation[] parameterTypes, TypeAnnotation returnType)

	def void addConstructorTypeDeclaration(ClassInstanceType receiver, TypeAnnotation[] parameterTypes)
	
	def void addVariableTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation type)
	
}