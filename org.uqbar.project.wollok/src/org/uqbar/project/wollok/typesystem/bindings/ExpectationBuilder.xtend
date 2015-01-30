package org.uqbar.project.wollok.typesystem.bindings

import org.eclipse.emf.ecore.EObject

/**
 * Extension provider to add all expectations to a TypedNode
 * while keeping the interface as DSL methods (operator overloading)
 * 
 * @author jfernandes
 */
class ExpectationBuilder {
	extension BoundsBasedTypeSystem t
	TypedNode node
	
	new(BoundsBasedTypeSystem system, TypedNode node) {
		t = system
		this.node = node
	}
	
	def void operator_greaterEqualsThan(EObject o1, EObject o2) {
		node.bindAsSuperTypeOf(o1.node, o2.node)
//		node.addExpectation(new SuperTypeExpectation(o1.node, o2.node))
//		o1.node.bindAsSuperTypeOf(o2.node)
	}
	
}