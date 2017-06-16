package org.uqbar.project.wollok.typesystem.declarations

import java.util.List

abstract class TypeDeclarations {
	TypeDeclarationTarget target
	String currentClassName


	static def addTypeDeclarations(TypeDeclarationTarget target, Class<? extends TypeDeclarations> declarations) {
		declarations.newInstance => [ 
			it.target = target
			it.declarations() 
		]
	}

	def void declarations()

	def type(String className, ()=>void typeDeclarations) {
		currentClassName = className
		typeDeclarations.apply
	}

	def operator(String selector, Pair<List<String>, String> methodType) {
		target.addTypeDeclaration(currentClassName, selector, methodType.key, methodType.value)
	}
	
	def operator_plus(String className, String parameterType) {
		new ExpectReturnType(target, className, "+", #[parameterType])
	}

	def operator_minus(String className, String parameterType) {
		new ExpectReturnType(target, className, "-", #[parameterType])
	}

	def operator_multiply(String className, String parameterType) {
		new ExpectReturnType(target, className, "*", #[parameterType])
	}
}

class ExpectReturnType {
	
	TypeDeclarationTarget target
	
	String className
	
	String selector
	
	List<String> parameterTypes
	
	new(TypeDeclarationTarget target, String className, String selector, List<String> parameterTypes) {
		this.target = target
		this.className = className
		this.selector = selector
		this.parameterTypes = parameterTypes
		
	}
	
	def operator_doubleArrow(String returnType) {
		target.addTypeDeclaration(className, selector, parameterTypes, returnType)
	}
}
