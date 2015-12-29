package org.uqbar.project.wollok.typesystem.bindings

import org.uqbar.project.wollok.typesystem.TypeExpectationFailedException
import org.uqbar.project.wollok.typesystem.WollokType

/**
 * A type expectation.
 * A rule that a type must complies in order to be valid.
 * 
 * @author jfernandes
 */
interface TypeExpectation {
	
	def void check(WollokType actualType) throws TypeExpectationFailedException
	
}