package org.uqbar.project.wollok.typesystem

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

/**
 * @author jfernandes
 */
class TypeSystemException extends RuntimeException {
	/**
	 * (Currently optional) type variable.
	 * This is highly coupled with ConstraintBasedTypeSystem, but given that we maybe deleting the others
	 * I thought it is not worth to do something more sophisticated to avoid the coupling.
	 * Anyway, other type systems should work correctly without a type variable assigned in their exceptions.
	 */
	@Accessors
	TypeVariable variable

	new() { }
	
	new(TypeVariable variable) { 
		if (!variable.owner.isCoreObject) {
			this.variable = variable
		}
	}
	
	new(String message) {
		super(message)
	}
	
	def relatedToType(WollokType type) { false }
	
}