package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.ClassInstanceType
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.StructuralType
import org.uqbar.project.wollok.typesystem.UnionType
import org.uqbar.project.wollok.typesystem.WollokType

class CompatibilityTypes {
	static val basicTypes = newArrayList("Number", "Boolean", "String")
	
	static def boolean isBasic(ClassInstanceType type) {
		basicTypes.contains(type.clazz.name)
	}

	/** Default behavior: any type is compatible with other */
	static def dispatch boolean isCompatible(WollokType supertype, WollokType subtype) {
		return true
	}
	
	/** Basic type is only compatible with itself */
	static def dispatch boolean isCompatible(ClassInstanceType supertype, ClassInstanceType subtype) {
		return 	(!supertype.isBasic && !subtype.isBasic) || supertype.clazz.name == subtype.clazz.name
	}
	
	static def dispatch boolean isCompatible(UnionType supertype, WollokType subtype) {
		return supertype.types.exists[isCompatible(subtype)]
	}
	
	static def dispatch boolean isCompatible(WollokType supertype, UnionType subtype) {
		return subtype.types.exists[isCompatible(supertype)]
	}

//	TODO: AnyType compatibility?	
//	/** Any is only compatible with itself */
//	static def dispatch boolean isCompatible(AnyType supertype, AnyType subtype) {
//		false
//	}
//	
//	/** Any is not compatible with another type */
//	static def dispatch boolean isCompatible(AnyType supertype, WollokType subtype) {
//		false
//	}
//
//	/** Any is not compatible with another type */
//	static def dispatch boolean isCompatible(WollokType supertype, AnyType subtype) {
//		false
//	}

	/** TODO Structural types */
	static def dispatch boolean isCompatible(WollokType supertype, StructuralType subtype) {
		throw new UnsupportedOperationException(Messages.RuntimeTypeSystemException_STRUCTURAL_TYPES_NOT_SUPPORTED)
	}

	/** TODO Structural types */
	static def dispatch boolean isCompatible(StructuralType supertype, WollokType subtype) {
		throw new UnsupportedOperationException(Messages.RuntimeTypeSystemException_STRUCTURAL_TYPES_NOT_SUPPORTED)
	}
}
