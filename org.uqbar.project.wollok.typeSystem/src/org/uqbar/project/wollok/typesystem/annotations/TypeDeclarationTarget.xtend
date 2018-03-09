package org.uqbar.project.wollok.typesystem.annotations

import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.ConcreteType

interface TypeDeclarationTarget {
	// TODO Is it ok to receive strings or should be have smarter types?
	def void addMethodTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation[] parameterTypes, TypeAnnotation returnType)

	def void addConstructorTypeDeclaration(ClassBasedWollokType receiver, TypeAnnotation[] parameterTypes)
	
}