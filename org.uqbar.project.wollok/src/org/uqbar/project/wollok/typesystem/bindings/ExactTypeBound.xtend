package org.uqbar.project.wollok.typesystem.bindings

import org.uqbar.project.wollok.semantics.WollokType

/**
 * type(from) == type(to)
 * 
 * @author jfernandes
 */
class ExactTypeBound extends TypeBound {
	
	new(TypedNode from, TypedNode to) {
		super(from, to)
	}
	
	override fromTypeChanged(WollokType newType) {
		propagate [ to.assignType(newType) ]
	}
	
	override toTypeChanged(WollokType newType) {
		propagate [	from.assignType(newType) ]
	}
	
	override toString() { '''«from» == «to»''' }
	
}