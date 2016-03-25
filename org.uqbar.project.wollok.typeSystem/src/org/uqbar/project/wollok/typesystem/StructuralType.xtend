package org.uqbar.project.wollok.typesystem

import java.util.Iterator
import java.util.List
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl

/**
 * 
 * @author jfernandes
 */
class StructuralType extends MinimalEObjectImpl.Container implements WollokType {
	List<MessageType> messages
	
	new(Iterator<MessageType> messagesTypes) {
		messages = messagesTypes.toList
	}
	
	override getName() { '{ ' + messages.join(' ; ') + ' }' }
	
	override getAllMessages() { messages }
	
	override acceptAssignment(WollokType other) {
		val notSupported = messages.filter[m| !other.understandsMessage(m)]
		if (notSupported.size > 0)
			throw new TypeSystemException("Incompatible type. Type «" + other + "» does not complaint the following messages: " + notSupported)
	}
	
	override refine(WollokType previous) {
		doRefine(previous)
	}
	
	def dispatch doRefine(StructuralType previouslyInferred) {
		val intersection = messages.filter[m| previouslyInferred.understandsMessage(m)]
		new StructuralType(intersection.iterator)
	}
	
	def dispatch doRefine(WollokType previouslyInferred) {
		throw new TypeSystemException("Incompatible types")		
	}
	
	override understandsMessage(MessageType message) { 
		messages.exists[message.isSubtypeof(it)]
	}
	
	override resolveReturnType(MessageType message) {
		//TODO !
		WAny
	}
	
	override toString() { name }
	
}