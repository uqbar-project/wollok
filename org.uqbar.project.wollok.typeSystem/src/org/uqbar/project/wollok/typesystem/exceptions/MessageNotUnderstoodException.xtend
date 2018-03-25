package org.uqbar.project.wollok.typesystem.exceptions

import org.uqbar.project.wollok.typesystem.AbstractContainerWollokType
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend

import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*

class MessageNotUnderstoodException extends TypeSystemException {
	WollokType type
	MessageSend messageSend
	
	new(WollokType type, MessageSend message) {
		this.type = type
		this.messageSend = message
		this.variable = message.returnType
	}

	override getMessage() {	message(type) }
	
	def dispatch message(WollokType type) {
		type.name.methodNotFoundMessage(messageSend.fullMessage.toString)
	}
	
	def dispatch message(AbstractContainerWollokType type) {
		type.container.methodNotFoundMessage(messageSend.selector, messageSend.argumentNames.toArray)
	}
}