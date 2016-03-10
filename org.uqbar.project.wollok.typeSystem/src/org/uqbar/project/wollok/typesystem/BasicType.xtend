package org.uqbar.project.wollok.typesystem

import org.eclipse.xtend.lib.Property

/**
 * Base class for all types
 * 
 * @author jfernandes
 */
abstract class BasicType implements WollokType {
	@Property String name
	
	new(String name) { 	
		this.name = name
	}
	
	override acceptAssignment(WollokType other) {
		if (other != this) 
			throw new TypeSystemException("Incompatible type")
	}
	
	//TODO: implementación default para no romper todo desde el inicio.
	// eventualmente cada type tiene que ir sobrescribiendo esto e implemetando la resolucion
	// de mensajes que entiende a metodos
	override understandsMessage(MessageType message) { true }
	override resolveReturnType(MessageType message) { WAny }
	
	override refine(WollokType previouslyInferred) {
		if (previouslyInferred != this) 
			throw new TypeSystemException("Incompatible type " + this + " is not compatible with " + previouslyInferred)
		// dummy impl
		previouslyInferred
	}
	
	// nothing !
	override getAllMessages() { #[] }
	
	override toString() { name }
}