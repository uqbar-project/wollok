package org.uqbar.project.wollok.typesystem.bindings

import org.uqbar.project.wollok.typesystem.TypeExpectationFailedException
import org.uqbar.project.wollok.typesystem.WollokType

/**
 * Expect the exact given type.
 * 
 * @author jfernandes
 */
class ExactTypeExpectation implements TypeExpectation {
	WollokType expectedType
	
	new(WollokType expected) {
		expectedType = expected 
	}
	
	override check(WollokType actualType) {
		if (expectedType != actualType)		
			throw new TypeExpectationFailedException('''expected <<«expectedType»>> but found <<«actualType»>>''')
	}
	
}