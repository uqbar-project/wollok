package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

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

	List<TypeSystemException> errors = newArrayList

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

	def addError(TypeSystemException exception) {
		errors.add(exception)
	}

	def hasErrors() {
		return !errors.empty
	}

	// REVIEW Is necessary to pass 'user'?
	def reportErrors(TypeVariable user, ConfigurableDslValidator validator) {
		errors.forEach [
			println(message)
			println(user.owner)
			try {
				validator.report(message, user.owner)
				// validator.report('''This statement does not produce a value''', user.owner)
			} catch (IllegalArgumentException e) {
				// TODO
			}
		]
	}

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	def void beSealed()

	def ConcreteTypeState addMinimalType(WollokType type)

	def void setMaximalConcreteTypes(MaximalConcreteTypes maxTypes)

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
