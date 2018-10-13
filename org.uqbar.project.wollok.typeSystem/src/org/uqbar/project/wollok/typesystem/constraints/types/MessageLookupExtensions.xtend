package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.MethodTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.MethodTypeProvider
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry

import static extension org.uqbar.project.wollok.typesystem.constraints.types.VariableSubtypingRules.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForAll
import static extension org.uqbar.project.wollok.utils.XtendExtensions.notNullAnd

/**
 * @author npasserini
 */
class MessageLookupExtensions {
	TypeVariablesRegistry registry
	extension MethodTypeProvider methodTypes

	new(TypeVariablesRegistry registry) {
		this.registry = registry
		this.methodTypes = new MethodTypeProvider(registry)
	}

	def static respondsToAll(WollokType type, Iterable<MessageSend> messages) {
		messages.forall[type.respondsTo(it)]
	}

	def static dispatch respondsTo(WollokType type, MessageSend message) {
		false
	}

	def static dispatch respondsTo(ConcreteType type, MessageSend message) {
		val registry = (type.typeSystem as ConstraintBasedTypeSystem).registry
		new MessageLookupExtensions(registry).canRespondTo(type, message)
	}

	def canRespondTo(ConcreteType it, MessageSend message) {
		// Decidir de dónde va a salir la info del mensaje.
		methodType(message).notNullAnd[matchesParameters(message)]
	}

	def matchesParameters(MethodTypeInfo method, MessageSend message) {
		return method.parameters.biForAll(message.arguments) [ parameter, argument |
			parameter.typeInfo.isSupertypeOf(argument.typeInfo)
		]
	}
}

