package org.uqbar.project.wollok.typesystem.substitutions

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType

/**
 * Abstract base class for a type system's rule.
 * 
 * @author jfernandes
 */
abstract class TypeRule {
	protected EObject source
	
	new(EObject source) {
		this.source = source
	}

	/**
	 * Tries to unify/resolve this rule.
	 * Returns true if something was resolved.
	 * This allows to perform many steps
	 * while still producing changes to rules
	 * and cut execution when it already finishes.
	 * 
	 * @return true if the rule changed. This allows the type system loop to go on one further step. 
	 */	
	def boolean resolve(SubstitutionBasedTypeSystem system)
	
	/**
	 * Returns the type for the given object, in case this rule knows about it.
	 */
	def WollokType typeOf(EObject object) { null }
	
	/** 
	 * If it's a check rule then it performs the check
	 * @throws TypeExpectationFailedException in case the check fails.
	 */
	def void check() {}
	
}