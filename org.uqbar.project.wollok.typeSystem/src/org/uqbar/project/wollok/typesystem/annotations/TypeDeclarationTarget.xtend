package org.uqbar.project.wollok.typesystem.annotations

import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.annotations.TypeAnnotation

interface TypeDeclarationTarget {
	// TODO Is it ok to receive strings or should be have smarter types?
	def void addTypeDeclaration(ConcreteType receiver, String selector, TypeAnnotation[] parameterTypes, TypeAnnotation returnType)
	
}