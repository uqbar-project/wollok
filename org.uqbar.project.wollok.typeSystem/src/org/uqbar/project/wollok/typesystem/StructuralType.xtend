package org.uqbar.project.wollok.typesystem

import java.util.Iterator
import java.util.List
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

/**
 * 
 * @author jfernandes
 */
class StructuralType extends MinimalEObjectImpl.Container implements WollokType {
	List<MessageType> messages
	
	new(Iterator<MessageType> messagesTypes) {
		messages = messagesTypes.toList
	}
	
	override instanceFor(TypeVariable tvar) {
		this
	}

	override getName() { '{ ' + messages.join(' ; ') + ' }' }
	
	override getAllMessages() { messages }
	
	override acceptsAssignment(WollokType other) {
		messages.exists[m| !other.understandsMessage(m)]
	}
	
	override acceptAssignment(WollokType other) {
		val notSupported = messages.filter[m| !other.understandsMessage(m)]
		if (notSupported.size > 0)
			throw new TypeSystemException(NLS.bind(Messages.TypeSystemException_INCOMPATIBLE_TYPE_NOT_SUPPORTED_MESSAGES, other, notSupported))
	}
	
	override refine(WollokType previous) {
		doRefine(previous)
	}
	
	def dispatch doRefine(StructuralType previouslyInferred) {
		val intersection = messages.filter[m| previouslyInferred.understandsMessage(m)]
		new StructuralType(intersection.iterator)
	}
	
	def dispatch doRefine(WollokType previouslyInferred) {
		throw new TypeSystemException(Messages.TypeSystemException_INCOMPATIBLE_TYPE)		
	}
	
	override understandsMessage(MessageType message) { 
		messages.exists[message.isSubtypeof(it)]
	}
	
	override resolveReturnType(MessageType message) {
		//TODO !
		WAny
	}
	
	override toString() { name }
	
	override beSubtypeOf(WollokType type) {
		// By default we have nothing to do, this is only for generic type instances to implement.
		// We could do some validation here, but a priori it does not seem to be mandatory.
	}
}