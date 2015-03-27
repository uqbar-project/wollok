package org.uqbar.project.wollok.typesystem.bindings

import org.uqbar.project.wollok.semantics.WollokType

/**
 * Represents a type binding between two ast nodes.
 * 
 * Meaning that element types are related in some way.
 * The exact relation depends on the type of bound.
 * 
 * This objects allow to assemble a nodes graph relating
 * type information.
 * This allows to calculate types later.
 * 
 * @author jfernandes
 */
abstract class TypeBound {
	val TypedNode from
	val TypedNode to
	boolean propagating
	
	new (TypedNode from, TypedNode to) {
		this.from = from
		this.to = to
		from.addListener[ newType | fromTypeChanged(newType) ]
		to.addListener[ newType | toTypeChanged(newType) ]
	}
	
	def TypedNode getFrom() { from }
	def TypedNode getTo() { to }
	
	def void inferTypes() {
		from.inferTypes
		to.inferTypes
	}
	
	// subclasses template methods
	
	def void fromTypeChanged(WollokType newType) {}
	def void toTypeChanged(WollokType newType) {}
	
	// helper method to control recursion while propagating events
	protected def propagate((Object)=>void block) {
		if (!propagating) {
			propagating = true
			block.apply(null)	
			propagating = false
		}
	}
	
	def boolean isFor(TypedNode node) { node == from || node == to }
	
}