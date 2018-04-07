package org.uqbar.project.wollok.typesystem.annotations

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.TypeProvider
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ClosureTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo

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
	def operator_doubleGreaterThan(SimpleTypeAnnotation<? extends ConcreteType> receiver, String selector) {
		new MethodIdentifier(target, receiver.type, selector)
	}

	def operator_doubleArrow(List<? extends TypeAnnotation> parameterTypes, TypeAnnotation returnType) {
		new MethodTypeDeclaration(parameterTypes, returnType)
	}
	
	def constructor(SimpleTypeAnnotation<? extends ClassBasedWollokType> owner, TypeAnnotation... parameterTypes) {
		target.addConstructorTypeDeclaration(owner.type, parameterTypes)
	}

	// ****************************************************************************
	// ** Synthetic operator syntax
	// ****************************************************************************
	def operator_equals(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "==", #[parameterType])
	}

	def operator_tripleEquals(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "===", #[parameterType])
	}
	
	def operator_plus(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "+", #[parameterType])
	}

	def operator_minus(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "-", #[parameterType])
	}

	def operator_multiply(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "*", #[parameterType])
	}

	def operator_divide(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "/", #[parameterType])
	}

	def operator_greaterThan(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, ">", #[parameterType])
	}

	def operator_lessThan(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "<", #[parameterType])
	}

	def operator_lessEqualsThan(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "<=", #[parameterType])
	}
	
	def operator_greaterEqualsThan(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, ">=", #[parameterType])
	}

	def operator_modulo(SimpleTypeAnnotation<? extends ConcreteType> receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "%", #[parameterType])
	}
	

	// ****************************************************************************
	// ** Core class and object types
	// ****************************************************************************
	def Void() { new VoidTypeAnnotation() }

	def Any() { new SimpleTypeAnnotation(WollokType.WAny) }

	def Object() { classTypeAnnotation(OBJECT) }

	def Boolean() { classTypeAnnotation(BOOLEAN) }

	def PairType() { genericTypeAnnotation(PAIR, GenericTypeInfo.KEY, GenericTypeInfo.VALUE) }
	
	def Number() { classTypeAnnotation(NUMBER) }

	def String() { classTypeAnnotation(STRING) }

	def Date() { classTypeAnnotation(DATE) }

	def List() { genericTypeAnnotation(LIST, GenericTypeInfo.ELEMENT) }

	def Set() { genericTypeAnnotation(SET, GenericTypeInfo.ELEMENT) }

	def Collection() { genericTypeAnnotation(COLLECTION, GenericTypeInfo.ELEMENT) }
	
	def Closure() { genericTypeAnnotation(CLOSURE, ClosureTypeInfo.RETURN) }

	def Range() { classTypeAnnotation(RANGE) }

	def Position() { classTypeAnnotation(POSITION) }

	def ExceptionType() { classTypeAnnotation(EXCEPTION) }

	def StackTraceElement() { classTypeAnnotation(STACK_TRACE_ELEMENT) }

	def InstanceVariableMirror() { classTypeAnnotation(INSTANCE_VARIABLE_MIRROR) }

	def console() { objectTypeAnnotation(CONSOLE) }
	
	def assertWKO() { objectTypeAnnotation(ASSERT) }
	
	def game() { objectTypeAnnotation(GAME) }
	
	def KEY() { PairType.param(GenericTypeInfo.KEY) }
	
	def VALUE() { PairType.param(GenericTypeInfo.VALUE) }
	
	def ELEMENT() { Collection.param(GenericTypeInfo.ELEMENT) }

	def RETURN() { Closure.param(ClosureTypeInfo.RETURN) }

	def classTypeAnnotation(String classFQN) { new SimpleTypeAnnotation(types.classType(context, classFQN)) }

	def objectTypeAnnotation(String objectFQN) { new SimpleTypeAnnotation(types.objectType(context, objectFQN)) }

	def genericTypeAnnotation(String classFQN, String... typeParameterNames) { 
		new SimpleTypeAnnotation(types.genericType(context, classFQN, typeParameterNames))
	}
	
	def closure(List<TypeAnnotation> parameters, TypeAnnotation returnType) {
		new ClosureTypeAnnotation(parameters, returnType)
	}
	
	def param(SimpleTypeAnnotation<GenericType> genericType, String paramName) {
		new ClassParameterTypeAnnotation(genericType.type, paramName)
	}
}

// ****************************************************************************
// ** DSL utility classes
// ****************************************************************************
class ExpectReturnType {

	TypeDeclarationTarget target

	ConcreteType receiver

	String selector

	List<TypeAnnotation> parameterTypes

	new(TypeDeclarationTarget target, ConcreteType receiver, String selector, List<TypeAnnotation> parameterTypes) {
		this.target = target
		this.receiver = receiver
		this.selector = selector
		this.parameterTypes = parameterTypes

	}

	def operator_doubleArrow(TypeAnnotation returnType) {
		target.addMethodTypeDeclaration(receiver, selector, parameterTypes, returnType)
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
		target.addMethodTypeDeclaration(receiver, selector, methodType.parameterTypes, methodType.returnType)
	}
}

class MethodTypeDeclaration {
	@Accessors
	List<? extends TypeAnnotation> parameterTypes

	@Accessors
	TypeAnnotation returnType

	new(List<? extends TypeAnnotation> parameterTypes, TypeAnnotation returnType) {
		this.parameterTypes = parameterTypes
		this.returnType = returnType
	}

}
