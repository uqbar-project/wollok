package org.uqbar.project.wollok.typesystem.constraints.types

import org.eclipse.xtend.lib.annotations.Accessors
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
	@Accessors(PUBLIC_GETTER) TypeVariablesRegistry registry
	extension MethodTypeProvider methodTypes

	new(TypeVariablesRegistry registry) {
		this.registry = registry
		this.methodTypes = new MethodTypeProvider(registry)
	}

	def static respondsToAll(WollokType type, Iterable<MessageSend> messages, boolean checkParameterTypes) {
		messages.forall[type.respondsTo(it, checkParameterTypes)]
	}

	def static dispatch respondsTo(WollokType type, MessageSend message, boolean checkParameterTypes) {
		false
	}

	def static dispatch respondsTo(ConcreteType type, MessageSend message, boolean checkParameterTypes) {
		val registry = (type.typeSystem as ConstraintBasedTypeSystem).registry
		new MessageLookupExtensions(registry).canRespondTo(type, message, checkParameterTypes)
	}

	def canRespondTo(ConcreteType it, MessageSend message, boolean checkParameterTypes) {
		// Decidir de dónde va a salir la info del mensaje.
		methodType(message).notNullAnd[matchesParameters(message, checkParameterTypes)]
	}

	/**
	 * Only check for parameter types if we are looking for maximal types, 
	 * so we can use parameter information to decide if the type is compliant with known usage. 
	 * Else, only check parameter count. 
	 * 
	 * This decission might need reviewing.
	 */
	def matchesParameters(MethodTypeInfo method, MessageSend message, boolean checkParameterTypes) {
		if(checkParameterTypes)
			method.parameters.biForAll(message.arguments) [ parameter, argument |
				parameter.typeInfo.isSupertypeOf(argument.typeInfo)
			]
		else method.parameters.size == message.arguments.size
	}
}
