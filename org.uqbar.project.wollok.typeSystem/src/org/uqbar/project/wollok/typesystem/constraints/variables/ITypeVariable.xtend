package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.WollokType

abstract class ITypeVariable {
	@Accessors
	val TypeVariableOwner owner
	
	new(TypeVariableOwner owner) {
		if (owner === null) 
			throw new IllegalArgumentException(Messages.RuntimeTypeSystemException_TYPE_VARIABLE_MUST_HAVE_AN_OWNER) 
		this.owner = owner
	}

	def void beSubtypeOf(ITypeVariable variable)

	def void beSupertypeOf(ITypeVariable variable)

	/**
	 * Creates a copy of this type variable, replacing parameters in the context of the received variable.
	 */
	def TypeVariable instanceFor(TypeVariable variable)

	/**
	 * Creates a copy of this type variable, replacing parameters in the context of the receiver type.
	 * E.g. method first in List hast type ()=>E, where E is the type of the elements of the list.
	 * 
	 * When E is used inside the program it is matched (via OpenMethod) with a message send to a concrete receiver, 
	 * e.g. a list of Numbers. In that case the type of the method has to be instantiated to ()=>Number.  
	 */
	def TypeVariable instanceFor(ConcreteType concreteReceiver)

	def WollokType getType()
}
