package org.uqbar.project.wollok.typesystem

import org.eclipse.xtend.lib.annotations.Accessors

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
			throw new TypeSystemException("Incompatible type")
	}
	
	//TODO: implementación default para no romper todo desde el inicio.
	// eventualmente cada type tiene que ir sobrescribiendo esto e implemetando la resolucion
	// de mensajes que entiende a metodos
	override understandsMessage(MessageType message) { true }
	override resolveReturnType(MessageType message) { WAny }
	
	def dispatch refine(WollokType previouslyInferred) {
		if (previouslyInferred != this) 
			throw new TypeSystemException("Incompatible type " + this + " is not compatible with " + previouslyInferred)
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
	
	override toString() { getName }
}