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
	def ConcreteTypeState addMinType(WollokType type)

	/**
	 * @param maxType A new set of maxTypes that will be merged with current maxTypes (or assigned if no current maxTypes).
	 * @origin The type variable from where we obtained this information, and will be target of error reports if any.
	 */
	def boolean setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable origin)

	// ************************************************************************
	// ** Notifications
	// ************************************************************************
	def void subtypeAdded() {}

	def void supertypeAdded() {}

	// ************************************************************************
	// ** Misc
	// ************************************************************************
	def String fullDescription()

}
