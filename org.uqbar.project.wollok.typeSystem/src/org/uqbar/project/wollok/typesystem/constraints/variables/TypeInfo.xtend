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

	def boolean hasErrors()

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	
	def void beSealed()

	def ConcreteTypeState addMinimalType(WollokType type)

	def void setMaximalConcreteTypes(MaximalConcreteTypes maxTypes)

	// ************************************************************************
	// ** Notifications
	// ************************************************************************

	def void subtypeAdded()
	def void supertypeAdded()
	
	// ************************************************************************
	// ** Misc
	// ************************************************************************

	def String fullDescription()
	
}
