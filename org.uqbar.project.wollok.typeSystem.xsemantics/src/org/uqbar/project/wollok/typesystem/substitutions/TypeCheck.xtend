package org.uqbar.project.wollok.typesystem.substitutions

import org.uqbar.project.wollok.semantics.TypeSystemException
import org.uqbar.project.wollok.semantics.WollokType
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException

/**
 * An object that checks a relation between two types.
 * 
 * @author jfernandes
 */
interface TypeCheck {
	def void check(WollokType a, WollokType b)
	
	public static val SAME_AS = new SameTypeCheck
	public static val SUPER_OF = new SuperTypeCheck
	
	def String getOperandString()
	
}

/**
 * Checks that two types are the same. 
 * 		a == b
 * @author jfernandes
 */
class SameTypeCheck implements TypeCheck {
	override check(WollokType a, WollokType b) {
		if (a != b) throw new TypeExpectationFailedException('''ERROR: expected <<«a»>> but found <<«b»>>''')
	}
	
	override getOperandString() { "==" }
	
}

/**
 * a >= b
 * 
 * @author jfernandes
 */
class SuperTypeCheck implements TypeCheck {
	override check(WollokType a, WollokType b) {
		try
			a.acceptAssignment(b)
		catch (TypeSystemException e)
			throw new TypeExpectationFailedException('''Expecting super type of <<«a»>> but found <<«b»>> which is not''')
	}
	
	override getOperandString() { "superTypeOf" }
	
}