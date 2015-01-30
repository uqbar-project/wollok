package org.uqbar.project.wollok.typesystem.bindings

import org.uqbar.project.wollok.semantics.WollokType
import org.eclipse.emf.ecore.EObject

/**
 * A type expectation.
 * A rule that a type must complies in order to be valid.
 * 
 * @author jfernandes
 */
interface TypeExpectation {
	
	def void check(WollokType actualType) throws TypeExpectationFailedException
	
}

/**
 * @author jfernandes
 */
class TypeExpectationFailedException extends RuntimeException {
	/** The semantic model (ast) which had this issue */
	@Property EObject model
	
	new(String message) {
		super(message)
	}
	
	new(EObject m, String message) {
		super(message)
		model = m
	}
	
}