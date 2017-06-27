package org.uqbar.project.wollok.typesystem.declarations

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.TypeProvider

import static org.uqbar.project.wollok.sdk.WollokDSK.*

abstract class TypeDeclarations {
	TypeDeclarationTarget target
	TypeProvider types
	EObject context

	static def addTypeDeclarations(TypeDeclarationTarget target, TypeProvider provider,
		Class<? extends TypeDeclarations> declarations, EObject context) {
		declarations.newInstance => [
			it.target = target
			it.types = provider
			it.context = context
			it.declarations()
		]
	}

	def void declarations()

	// ****************************************************************************
	// ** General syntax
	// ****************************************************************************
	def operator_doubleGreaterThan(ConcreteType receiver, String selector) {
		new MethodIdentifier(target, receiver, selector)
	}

	def operator_doubleArrow(List<String> parameterTypeNames, String returnTypeName) {
		new MethodTypeDeclaration(parameterTypeNames, returnTypeName)
	}

	// ****************************************************************************
	// ** Synthetic operator syntax
	// ****************************************************************************
	def operator_plus(ConcreteType receiver, String parameterType) {
		new ExpectReturnType(target, receiver, "+", #[parameterType])
	}

	def operator_minus(ConcreteType receiver, String parameterType) {
		new ExpectReturnType(target, receiver, "-", #[parameterType])
	}

	def operator_multiply(ConcreteType receiver, String parameterType) {
		new ExpectReturnType(target, receiver, "*", #[parameterType])
	}

	// ****************************************************************************
	// ** Core classes and object
	// ****************************************************************************
	def Integer() { types.classType(context, INTEGER) }
	def String() { types.classType(context, STRING )}
	def List() { types.classType(context, LIST) }
	def Set() { types.classType(context, COLLECTION) }
	def Collection() { types.classType(context, SET) }
	
	def console() { types.objectType(context, CONSOLE)}
}

// ****************************************************************************
// ** DSL utility classes
// ****************************************************************************
class ExpectReturnType {

	TypeDeclarationTarget target

	ConcreteType receiver

	String selector

	List<String> parameterTypes

	new(TypeDeclarationTarget target, ConcreteType receiver, String selector, List<String> parameterTypes) {
		this.target = target
		this.receiver = receiver
		this.selector = selector
		this.parameterTypes = parameterTypes

	}

	def operator_doubleArrow(String returnType) {
		target.addTypeDeclaration(receiver, selector, parameterTypes, returnType)
	}
}

class MethodIdentifier {
	TypeDeclarationTarget target
	ConcreteType receiver
	String selector

	new(TypeDeclarationTarget target, ConcreteType receiver, String selector) {
		this.target = target
		this.receiver = receiver
		this.selector = selector
	}

	def operator_tripleEquals(MethodTypeDeclaration methodType) {
		target.addTypeDeclaration(receiver, selector, methodType.parameterTypeNames, methodType.returnTypeName)
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
