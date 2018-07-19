package org.uqbar.project.wollok.typesystem.annotations

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.WollokType

interface TypeAnnotation {
}

class SimpleTypeAnnotation<T extends WollokType> implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	T type

	new(T type) {
		this.type = type
	}
}

/**
 * TODO Validar: usar esto como annotation es dudoso, ya que no es un "tipo", solo las instancias 
 * (obtenidas mediante #of o #instance son tipos válidos).
 * 
 * Por ahora se permite, un poco por compatibilidad hacia atrás.
 */
class GenericTypeAnnotation extends SimpleTypeAnnotation<GenericType> {
	
	new(GenericType type) {
		super(type)
	}
	
	def of(TypeAnnotation uniqueTypeParameter) {
		instance(#{ type.typeParameterNames.head -> uniqueTypeParameter })
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
		this.type = type
		this.paramName = paramName
	}
}

class VoidTypeAnnotation implements TypeAnnotation {}

class GenericTypeInstanceAnnotation extends SimpleTypeAnnotation<GenericType> {
	@Accessors(PUBLIC_GETTER)
	Map<String, TypeAnnotation> typeParameters
	
	new(GenericType closureType, Map<String, TypeAnnotation> typeParameters) {
		super(closureType)
		this.typeParameters = typeParameters
	}
}
