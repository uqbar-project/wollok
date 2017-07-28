package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.AbstractContainerWollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForAll
import static extension org.uqbar.project.wollok.typesystem.constraints.types.VariableSubtypingRules.*

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

class MessageLookupExtensions {
	TypeVariablesRegistry registry

	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def static respondsTo(AbstractContainerWollokType type, MessageSend message) {
		new MessageLookupExtensions(type.registry).canRespondTo(type, message)
	}

	def static getRegistry(AbstractContainerWollokType type) {
		(type.typeSystem as ConstraintBasedTypeSystem).registry
	}

	def canRespondTo(AbstractContainerWollokType it, MessageSend message) {
		container.allMethods.exists [ method |
			match(method, message)
		]
	}

	def private match(WMethodDeclaration declaration, MessageSend message) {
		declaration.name == message.selector && declaration.parameters.size == message.arguments.size &&
			matchParameters(declaration, message)
	}

	def private matchParameters(WMethodDeclaration method, MessageSend message) {
		return method.parameters.biForAll(message.arguments) [ parameter, argument |
			try {
				registry.tvar(parameter).typeInfo.isSupertypeOf(argument.typeInfo)
			} catch (RuntimeException exception) {
				// This is most probably because lack of a type annotation, ignore it for now.
				true
			}
		]
	}
}
