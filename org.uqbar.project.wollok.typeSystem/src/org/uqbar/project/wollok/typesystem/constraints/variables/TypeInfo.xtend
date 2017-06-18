package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Map
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
	// ** Users
	// ************************************************************************
	def getCanonicalUser() {
		users.get(0)
	}

	def addUser(TypeVariable variable) {
		users.add(variable)
	}

	// ************************************************************************
	// ** TBC
	// ************************************************************************

	def void beSealed()

	def WollokType getType(TypeVariable tvar)

	def boolean hasErrors()

	def ConcreteTypeState addMinimalType(WollokType type)

	def Map<WollokType, ConcreteTypeState> getMinimalConcreteTypes()
	def void setMinimalConcreteTypes(Map<WollokType, ConcreteTypeState> minTypes)

	def MaximalConcreteTypes getMaximalConcreteTypes()
	def void setMaximalConcreteTypes(MaximalConcreteTypes maxTypes)
	def void joinMaxTypes(MaximalConcreteTypes types)
}
