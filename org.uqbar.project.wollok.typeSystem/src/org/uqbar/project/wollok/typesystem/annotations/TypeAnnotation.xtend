package org.uqbar.project.wollok.typesystem.annotations

import org.eclipse.xtend.lib.annotations.Accessors
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

class ClassParameterTypeAnnotation implements TypeAnnotation {
	@Accessors
	String paramName

	new(String paramName) {
		this.paramName = paramName
	}
}


class VoidTypeAnnotation implements TypeAnnotation {}
