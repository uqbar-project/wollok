package org.uqbar.project.wollok.typesystem.declarations

import org.uqbar.project.wollok.typesystem.ConcreteType

interface TypeDeclarationTarget {
	// TODO Is it ok to receive strings or should be have smarter types?
	def void addTypeDeclaration(ConcreteType receiver, String selector, String[] parameterTypes, String returnType)
	
}