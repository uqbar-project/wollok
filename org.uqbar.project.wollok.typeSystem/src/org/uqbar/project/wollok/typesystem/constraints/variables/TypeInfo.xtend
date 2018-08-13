package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.WollokType

abstract class TypeInfo {
	@Accessors(PUBLIC_GETTER)
	val List<TypeVariable> users = newArrayList

	@Accessors
	val List<MessageSend> messages = newArrayList

	/**
	 * A sealed variable can not be further restricted. 
	 * Minimal and maximal concrete type sets should be equal after sealing a variable. 
	 */
	@Accessors(PUBLIC_GETTER)
	var Boolean sealed = false

	// ************************************************************************
	// ** Type info users
	// ************************************************************************
	def getCanonicalUser() {
		users.get(0)
	}

	def addUser(TypeVariable variable) {
		users.add(variable)
	}

	// ************************************************************************
	// ** Queries
	// ************************************************************************
	def WollokType getType(TypeVariable user)

	def Iterable<MessageSend> validMessages() { messages.filter[ message | message.isValid] }

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	def void beSealed() {
		sealed = true
	}

	/**
	 * @param type A new type to be added
	 * @param origin The variable which provided the information for this added type and should be target of potential error reports
	 */
	def ConcreteTypeState addMinType(WollokType type, TypeVariable origin)

	/**
	 * @param maxType A new set of maxTypes that will be merged with current maxTypes (or assigned if no current maxTypes).
	 * @offender The type variable to which we should report errors if this operation is not possible
	 */
	def boolean setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable offender)

	// ************************************************************************
	// ** Notifications
	// ************************************************************************
	def void subtypeAdded(TypeVariable subtype) {}

	def void supertypeAdded(TypeVariable supertype) {}

	// ************************************************************************
	// ** Debug
	// ************************************************************************
	def String fullDescription()

	def String typeDescriptionForDebug()

}
