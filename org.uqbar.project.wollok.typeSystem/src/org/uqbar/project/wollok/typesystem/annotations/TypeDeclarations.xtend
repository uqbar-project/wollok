package org.uqbar.project.wollok.typesystem.annotations

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ClassInstanceType
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.TypeProvider
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

abstract class TypeDeclarations {
	TypeDeclarationTarget target
	TypeProvider types
	EObject context

	static def addTypeDeclarations(TypeDeclarationTarget target, TypeProvider provider, EObject context,
		Class<? extends TypeDeclarations>... declarations) {
		declarations.forEach [
			newInstance => [
				it.target = target
				it.types = provider
				it.context = context
				it.declarations()
			]
		]
	}

	def void declarations()

	// ****************************************************************************
	// ** General syntax
	// ****************************************************************************
	def allMethods(SimpleTypeAnnotation<? extends ConcreteType> receiver) {
		new AllMethodsIdentifier(target, receiver.type)
	}

	def operator_doubleGreaterThan(AnnotationContext receiver, String selector) {
		new MethodIdentifier(target, receiver.type, selector)
	}

	def operator_doubleArrow(List<? extends TypeAnnotation> parameterTypes, TypeAnnotation returnType) {
		new MethodTypeDeclaration(parameterTypes, returnType)
	}

	def constructor(AnnotationContext owner, TypeAnnotation... parameterTypes) {
		target.addConstructorTypeDeclaration(owner.type as ClassInstanceType, parameterTypes)
	}

	def variable(AnnotationContext owner, String selector, TypeAnnotation type) {
		target.addVariableTypeDeclaration(owner.type, selector, type)
	}

	// ****************************************************************************
	// ** Synthetic operator syntax
	// ****************************************************************************
	def operator_equals(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "==", #[parameterType])
	}

	def operator_tripleEquals(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "===", #[parameterType])
	}
	
	def operator_notEquals(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "!=", #[parameterType])
	}

	def operator_tripleNotEquals(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "!==", #[parameterType])
	}

	def operator_mappedTo(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "->", #[parameterType])
	}

	def operator_plus(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "+", #[parameterType])
	}

	def operator_minus(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "-", #[parameterType])
	}

	def operator_multiply(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "*", #[parameterType])
	}

	def operator_divide(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "/", #[parameterType])
	}

	def operator_greaterThan(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, ">", #[parameterType])
	}

	def operator_lessThan(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "<", #[parameterType])
	}

	def operator_lessEqualsThan(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "<=", #[parameterType])
	}

	def operator_greaterEqualsThan(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, ">=", #[parameterType])
	}

	def operator_modulo(AnnotationContext receiver, TypeAnnotation parameterType) {
		new ExpectReturnType(target, receiver.type, "%", #[parameterType])
	}

	// ****************************************************************************
	// ** Shortcuts and helpers
	// ****************************************************************************
	def comparable(ConcreteTypeAnnotation T) {
		(T > T) => Boolean;
		(T < T) => Boolean;
		(T <= T) => Boolean;
		(T >= T) => Boolean;
		(T === T) => Boolean;
	}

	def fakeProperty(ConcreteTypeAnnotation it, String property, TypeAnnotation type) {
		it >> property === #[type] => Void
		it >> property === #[] => type
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

	def Closure() { genericTypeAnnotation(CLOSURE, GenericTypeInfo.RETURN) }

	def Range() { classTypeAnnotation(RANGE) }

	def Dictionary() { genericTypeAnnotation(DICTIONARY, GenericTypeInfo.KEY, GenericTypeInfo.VALUE) }

	def Position() { classTypeAnnotation(POSITION) }

	def Key() { classTypeAnnotation(KEY) }

	def ExceptionType() { classTypeAnnotation(EXCEPTION) }

	def StackTraceElement() { classTypeAnnotation(STACK_TRACE_ELEMENT) }

	def InstanceVariableMirror() { classTypeAnnotation(INSTANCE_VARIABLE_MIRROR) }

	def StringPrinter() { classTypeAnnotation(STRING_PRINTER) }

	def console() { objectTypeAnnotation(CONSOLE) }

	def assertWKO() { objectTypeAnnotation(ASSERT) }

	def game() { objectTypeAnnotation(GAME) }

	def keyboard() { objectTypeAnnotation(KEYBOARD) }

	def PKEY() { PairType.param(GenericTypeInfo.KEY) }

	def PVALUE() { PairType.param(GenericTypeInfo.VALUE) }

	def DKEY() { Dictionary.param(GenericTypeInfo.KEY) }

	def DVALUE() { Dictionary.param(GenericTypeInfo.VALUE) }

	def ELEMENT() { Collection.param(GenericTypeInfo.ELEMENT) }

	def T() { Collection.methodParam("map", "T") }

	def RETURN() { Closure.param(GenericTypeInfo.RETURN) }

	def classTypeAnnotation(String classFQN) { new ConcreteTypeAnnotation(types.classType(context, classFQN)) }

	def objectTypeAnnotation(String objectFQN) { new ConcreteTypeAnnotation(types.objectType(context, objectFQN)) }

	def genericTypeAnnotation(String classFQN, String... typeParameterNames) {
		new GenericTypeAnnotationFactory(types.genericType(context, classFQN, typeParameterNames))
	}

	def closure(List<TypeAnnotation> parameters, TypeAnnotation returnType) {
		val typeParameters = newHashMap => [ map |
			map.put(GenericTypeInfo.RETURN, returnType)
			parameters.forEach [ parameter, index |
				map.put(GenericTypeInfo.PARAM(index), parameter)
			]
		]

		new GenericTypeAnnotationFactory(types.closureType(context, parameters.length)).instance(typeParameters)
	}

	def predicate(TypeAnnotation... input) {
		closure(input, Boolean)
	}
	
	def allTypes() { types.allTypes.map[ new ConcreteTypeAnnotation(baseType)] }
	
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

class AllMethodsIdentifier {
	Iterable<MethodIdentifier> identifiers

	new(TypeDeclarationTarget target, ConcreteType receiver) {
		identifiers = receiver.container.methods.map[new MethodIdentifier(target, receiver, name)]
	}

	def operator_tripleEquals(MethodTypeDeclaration methodType) {
		identifiers.forEach[it === methodType]
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
