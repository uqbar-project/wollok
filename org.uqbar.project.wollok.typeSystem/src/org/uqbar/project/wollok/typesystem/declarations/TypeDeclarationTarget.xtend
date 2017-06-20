package org.uqbar.project.wollok.typesystem.declarations

interface TypeDeclarationTarget {
	// TODO Is it ok to receive strings or should be have smarter types?
	def void addTypeDeclaration(String typeName, String selector, String[] parameterTypes, String returnType)
	
}