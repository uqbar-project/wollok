package org.uqbar.project.wollok.typesystem.annotations

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.WollokType

interface AnnotationContext {
	def ConcreteType getType()	
}

interface TypeAnnotation {
}

class SimpleTypeAnnotation<T extends WollokType> implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	val T type

	new(T type) {
		this.type = type
	}
}

class ConcreteTypeAnnotation extends SimpleTypeAnnotation<ConcreteType> implements AnnotationContext {
	new(ConcreteType type) {
		super(type)
	}
}

/**
 * This allows to create annotations for generic types.
 */
class GenericTypeAnnotationFactory implements AnnotationContext {
	@Accessors
	val GenericType type

	new(GenericType type) {
		this.type = type
	}

	/**
	 * Creates a class-parameter type annotation for one type parameter of this generic type.
	 */
	def param(String paramName) {
		new ClassParameterTypeAnnotation(type, paramName)
	}

	/**
	 * Utility method, simplified version of #instance for generic types with only one type parameter.
	 */
	def of(TypeAnnotation uniqueTypeParameter) {
		instance(#{type.typeParameterNames.head -> uniqueTypeParameter})
	}

	def instance(Map<String, TypeAnnotation> typeParameters) {
		new GenericTypeInstanceAnnotation(type, typeParameters)
	}
}

class ClassParameterTypeAnnotation implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	GenericType type

	@Accessors(PUBLIC_GETTER)
	String paramName

	new(GenericType type, String paramName) {
		if (!type.typeParameterNames.contains(paramName)) {
			throw new IllegalArgumentException('''Bad type annotation, type «type» does not contain a class parameter named «paramName»''')
		}

		this.type = type
		this.paramName = paramName
	}
}

class VoidTypeAnnotation implements TypeAnnotation {
}

class GenericTypeInstanceAnnotation extends SimpleTypeAnnotation<GenericType> {
	@Accessors(PUBLIC_GETTER)
	Map<String, TypeAnnotation> typeParameters

	new(GenericType closureType, Map<String, TypeAnnotation> typeParameters) {
		super(closureType)
		this.typeParameters = typeParameters
	}
}
