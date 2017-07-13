package org.uqbar.project.wollok.typesystem.annotations

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.WollokType
import java.util.List

interface TypeAnnotation {
}

class SimpleTypeAnnotation<T extends WollokType> implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	T type

	new(T type) {
		this.type = type
	}
}

class ClassParameterTypeAnnotation implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	String paramName

	new(String paramName) {
		this.paramName = paramName
	}
}


class VoidTypeAnnotation implements TypeAnnotation {}

class ClosureTypeAnnotation implements TypeAnnotation {
	@Accessors(PUBLIC_GETTER)
	List<TypeAnnotation> parameters
	
	@Accessors(PUBLIC_GETTER)
	TypeAnnotation returnType
	
	new(List<TypeAnnotation> parameters, TypeAnnotation returnType) {
		this.parameters = parameters
		this.returnType = returnType
	}
	
}