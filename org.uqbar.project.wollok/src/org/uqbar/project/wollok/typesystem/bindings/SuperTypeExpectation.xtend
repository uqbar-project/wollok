package org.uqbar.project.wollok.typesystem.bindings

import org.uqbar.project.wollok.semantics.TypeSystemException
import org.uqbar.project.wollok.semantics.WollokType

/**
 * Expect the given type to be the same or 
 * a supertype of the other.
 * 
 * @author jfernandes
 */
class SuperTypeExpectation implements TypeExpectation {
	TypedNode from
	TypedNode to
	
	new(TypedNode from, TypedNode to) {
		this.from = from
		this.to = to
	}
	
	override check(WollokType actualType) throws TypeExpectationFailedException {
		try
			from.type.acceptAssignment(to.type)
		catch (TypeSystemException e)
			throw new TypeExpectationFailedException('''Expecting super type of <<«to.type»>> but found <<«from.type»>> which is not''')
	}
	
}