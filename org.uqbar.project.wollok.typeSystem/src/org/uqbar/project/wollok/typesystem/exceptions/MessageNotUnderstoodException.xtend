package org.uqbar.project.wollok.typesystem.exceptions

import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages

class MessageNotUnderstoodException extends TypeSystemException {
	WollokType type
	MessageSend messageSend
	
	/**
	 * This constructor allows for a later assignment of the offending variable, 
	 * for cases in which we want a more sophisticated algorithm for determining it.
	 */
	new(WollokType type, MessageSend message) {
		this.type = type
		this.messageSend = message
		this.variable = message.returnType
	}

	override getMessage() {
		NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST, type.name, messageSend.fullMessage)
	}	
}