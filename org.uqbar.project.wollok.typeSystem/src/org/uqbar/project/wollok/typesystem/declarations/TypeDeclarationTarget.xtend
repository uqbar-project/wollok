package org.uqbar.project.wollok.typesystem.declarations

import java.util.List

interface TypeDeclarationTarget {
	// TODO Is it ok to receive strings or should be have smarter types?
	def void addTypeDeclaration(String typeName, String selector, List<String> parameterTypes, String returnType)
	
}