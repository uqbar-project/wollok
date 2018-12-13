package org.uqbar.project.wollok.typesystem

import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

/**
 * Base class for all types
 * 
 * @author jfernandes
 */
abstract class BasicType implements WollokType {
	@Accessors String name
	
	new(String name) { 	
		this.name = name
	}
	
	override acceptsAssignment(WollokType other) {
		other == this
	}

	override acceptAssignment(WollokType other) {
		if (!acceptsAssignment(other)) 
			throw new TypeSystemException(Messages.TypeSystemException_INCOMPATIBLE_TYPE)
	}
	
	//TODO: implementación default para no romper todo desde el inicio.
	// eventualmente cada type tiene que ir sobrescribiendo esto e implemetando la resolucion
	// de mensajes que entiende a metodos
	override understandsMessage(MessageType message) { true }
	override resolveReturnType(MessageType message) { WAny }
	
	def dispatch refine(WollokType previouslyInferred) {
		if (previouslyInferred != this) 
			throw new TypeSystemException(NLS.bind(Messages.TypeSystemException_INCOMPATIBLE_TYPE_DETAILED, this, previouslyInferred))
		// dummy impl
		previouslyInferred
	}
	
	/**
	 * {@link AnyType} can be refined to any other type. 
	 */
	def dispatch refine(AnyType previouslyInferred) { 
		this
	}
	
	// nothing !
	override getAllMessages() { #[] }

	override instanceFor(TypeVariable parent) { this }

	override toString() { getName }
	
	override beSubtypeOf(WollokType type) {
		// By default we have nothing to do, this is only for generic type instances to implement.
		// We could do some validation here, but a priori it does not seem to be mandatory.
	}
}