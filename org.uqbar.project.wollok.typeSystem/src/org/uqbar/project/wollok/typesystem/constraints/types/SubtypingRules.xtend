package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.AnyType
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.StructuralType
import org.uqbar.project.wollok.typesystem.WollokType

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class SubtypingRules {
	
	/** Default behavior: any type is supertype of itself */
	static def dispatch boolean isSuperTypeOf(WollokType supertype, WollokType subtype) {
		return supertype == subtype
	}

	/** Any is supertype of everything */
	static def dispatch isSuperTypeOf(AnyType supertype, WollokType subtype) {
		true
	}

	/** No type is supertype of Any */
	static def dispatch isSuperTypeOf(WollokType supertype, AnyType subtype) {
		false
	}

	/** TODO Structural types */
	static def dispatch isSuperTypeOf(StructuralType supertype, WollokType subtype) {
		throw new UnsupportedOperationException("Structural types are not supported yet. ")
	}

	/** TODO Structural types */
	static def dispatch isSuperTypeOf(ClassBasedWollokType supertype, ClassBasedWollokType subtype) {
		supertype.clazz.isSuperTypeOf(subtype.clazz)
	}

	/** TODO Structural types */
	static def dispatch isSuperTypeOf(WollokType supertype, StructuralType subtype) {
		throw new UnsupportedOperationException("Structural types are not supported yet. ")
	}
}
