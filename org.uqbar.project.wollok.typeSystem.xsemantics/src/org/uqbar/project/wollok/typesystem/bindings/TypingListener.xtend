package org.uqbar.project.wollok.typesystem.bindings

import org.uqbar.project.wollok.typesystem.WollokType

/**
 * An object that registers itself into a TypedNode
 * in order to keep track of type inference.
 * 
 * Actually the different TypeBounds are listeners
 * on nodes.
 * So that, when one side of the bound gets "fixed" or resolved
 * into a type, it propagates the type accordingly.
 * 
 * @author jfernandes
 */
interface TypingListener {
	
	/**
	 * Notifies this listener that the given type was resolved for 
	 * the node.
	 */
	def void notifyTypeSet(WollokType t)
	
}