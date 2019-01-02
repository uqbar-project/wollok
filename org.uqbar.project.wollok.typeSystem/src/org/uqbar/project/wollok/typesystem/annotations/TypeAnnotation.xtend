package org.uqbar.project.wollok.typesystem.annotations

import java.util.Map
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.WollokType

/**
 * A concrete class or WKO which's methods we want to annotate.
 */
interface AnnotationContext {
	def ConcreteType getType()
}

/**
 * The definition of a type for a parameter of a return value of a method in an AnnotationContext 
 */
interface TypeAnnotation {
}

/**
 * This should be used only for non-concrete types, such as Any.
 */
class SimpleTypeAnnotation<T extends WollokType> implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	val T type

	new(T type) {
		this.type = type
	}
}

/**
 * Can be used both as type annotation and as annotation context.
 * Conceptually is weird, but it makes suitable to build the annotation DSL on top of this.
 */
class ConcreteTypeAnnotation extends SimpleTypeAnnotation<ConcreteType> implements AnnotationContext {
	new(ConcreteType type) {
		super(type)
	}
}

/**
 * This allows to create annotations for generic types.
 * Also it can be used as an annotation context for the methods of the generic type.
 */
class GenericTypeAnnotationFactory implements AnnotationContext {
	val GenericType genericType

	new(GenericType genericType) {
		this.genericType = genericType
	}

	/**
	 * This allows the type annotation to be used as annotation context, i.e. annotate the methods of the base type (a class)
	 * of this generic type.
	 */
	override getType() {
		genericType.baseType
	}

	/**
	 * Creates a class-parameter type annotation for one type parameter of this generic type.
	 */
	def param(String paramName) {
		new ClassTypeParameterAnnotation(genericType, paramName)
	}

	/**
	 * Creates a class-parameter type annotation for one type parameter of this generic type.
	 */
	def methodParam(String methodName, String paramName) {
		new MethodTypeParameterAnnotation(genericType, methodName, paramName)
	}

	/**
	 * Utility method, simplified version of #instance for generic types with only one type parameter.
	 */
	def of(TypeAnnotation uniqueTypeParameter) {
		instance(#{genericType.typeParameterNames.head -> uniqueTypeParameter})
	}

	def instance(Map<String, TypeAnnotation> typeParameters) {
		new GenericTypeInstanceAnnotation(genericType, typeParameters)
	}
}

class ClassTypeParameterAnnotation implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	GenericType type

	@Accessors(PUBLIC_GETTER)
	String paramName

	new(GenericType type, String paramName) {
		if(!type.typeParameterNames.contains(paramName)) {
			throw new IllegalArgumentException(
				NLS.bind(Messages.RuntimeTypeSystemException_BAD_TYPE_ANNOTATION, type, paramName))
		}

		this.type = type
		this.paramName = paramName
	}
}

class MethodTypeParameterAnnotation implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	GenericType type

	@Accessors(PUBLIC_GETTER)
	String methodName

	@Accessors(PUBLIC_GETTER)
	String paramName

	new(GenericType type, String methodName, String paramName) {
		this.type = type
		this.methodName = methodName
		this.paramName = paramName
	}
}

class VoidTypeAnnotation implements TypeAnnotation {
}

class GenericTypeInstanceAnnotation implements TypeAnnotation {
	@Accessors
	val GenericType type

	@Accessors
	val Map<String, TypeAnnotation> typeParameters

	new(GenericType type, Map<String, TypeAnnotation> typeParameters) {
		this.type = type
		this.typeParameters = typeParameters
	}
}

/**
 * This allows to annotate something to be of the same type as the receiver. E.g. several collection 
 * methods return objects of the same type of the receiver: Set.filter returns a Set and List.filter returns a List.
 * 
 * Right now this is only implemented self types for generic types with a single type parameter (such as collections)
 */
class GenericSelfTypeInstanceAnnotation implements TypeAnnotation {
	@Accessors
	TypeAnnotation uniqueTypeParameter

	new(TypeAnnotation uniqueTypeParameter) {
		this.uniqueTypeParameter = uniqueTypeParameter
	}
}

/** Helper for the type declaration DSL to create SelfType annotations */
class SelfType {
	static def of(TypeAnnotation uniqueTypeParameter) {
		new GenericSelfTypeInstanceAnnotation(uniqueTypeParameter)
	}
}

