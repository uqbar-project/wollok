package org.uqbar.project.wollok.typesystem.declarations

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

abstract class TypeDeclarations {
	TypeDeclarationTarget target

	static def addTypeDeclarations(TypeDeclarationTarget target, Class<? extends TypeDeclarations> declarations) {
		declarations.newInstance => [
			it.target = target
			it.declarations()
		]
	}

	def void declarations()

	// ****************************************************************************
	// ** General syntax
	// ****************************************************************************
	def operator_doubleGreaterThan(String className, String selector) {
		new MethodIdentifier(target, className, selector)
	}

	def operator_doubleArrow(List<String> parameterTypeNames, String returnTypeName) {
		new MethodTypeDeclaration(parameterTypeNames, returnTypeName)
	}

	// ****************************************************************************
	// ** Synthetic operator syntax
	// ****************************************************************************
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

// ****************************************************************************
// ** DSL utility classes
// ****************************************************************************
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

class MethodIdentifier {
	TypeDeclarationTarget target
	String className
	String selector

	new(TypeDeclarationTarget target, String className, String selector) {
		this.target = target
		this.className = className
		this.selector = selector
	}

	def operator_tripleEquals(MethodTypeDeclaration methodType) {
		target.addTypeDeclaration(className, selector, methodType.parameterTypeNames, methodType.returnTypeName)
	}
}

class MethodTypeDeclaration {
	@Accessors
	List<String> parameterTypeNames

	@Accessors
	String returnTypeName

	new(List<String> parameterTypeNames, String returnTypeName) {
		this.parameterTypeNames = parameterTypeNames
		this.returnTypeName = returnTypeName
	}

}
