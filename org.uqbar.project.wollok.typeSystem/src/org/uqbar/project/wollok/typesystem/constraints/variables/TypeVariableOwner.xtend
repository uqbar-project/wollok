package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.exceptions.CannotBeVoidException
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

import static extension org.uqbar.project.wollok.scoping.WollokResourceCache.isCoreObject
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo.canBeVoid
import org.eclipse.emf.ecore.util.EcoreUtil

/**
 * Type variables are most typically associated to a program element, but in the presence of generics there exist
 * some variables that can not be linked to a specific element. E.g. var l = [1,2,3], l has a type variable
 * that will resolve to type List, but we also need a type variable that will be used to compute the type of the
 * elements of the list (in this example: Number). So we need a new type variable, that can't be associated to any
 * node in the AST of the example program. The derived type variable will be a dependent type variable from the 'main' 
 * type variable of element `l`.
 * 
 * This abstract class is the super class of all possible `owners` of a type variable.
 */
abstract class TypeVariableOwner {
	@Accessors
	val log = Logger.getLogger(class)

	// ************************************************************************
	// ** Information
	// ************************************************************************
	def URI getURI()

	def boolean isCoreObject()

	def void checkCanBeVoid()

	// ************************************************************************
	// ** Error handling
	// ************************************************************************
	def void addError(TypeSystemException exception)

	def hasErrors() {
		!this.errors.empty
	}

	def Iterable<TypeSystemException> getErrors()

	def void reportErrors(ConfigurableDslValidator validator)

	def EObject getErrorReportTarget()

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	def String debugInfo()

	def String debugInfoInContext()

	// ************************************************************************
	// ** Static helpers
	// ************************************************************************
	static def URI getURI(EObject object) {
		EcoreUtil.getURI(object)
	}

}

class ProgramElementTypeVariableOwner extends TypeVariableOwner {
	@Accessors
	val EObject programElement

	@Accessors(PUBLIC_GETTER)
	List<TypeSystemException> errors = newArrayList

	new(EObject programElement) {
		if(programElement === null) throw new IllegalArgumentException(class.simpleName + " requires a program element")
		this.programElement = programElement
	}

	// ************************************************************************
	// ** Information
	// ************************************************************************
	override getURI() {
		programElement.URI
	}

	override isCoreObject() {
		programElement.isCoreObject
	}

	override checkCanBeVoid() {
		if (!programElement.canBeVoid) {
			throw new CannotBeVoidException(programElement)
		}
	}

	// ************************************************************************
	// ** Error handling
	// ************************************************************************
	override addError(TypeSystemException exception) {
		if (isCoreObject)
			throw new RuntimeException('''Tried to add a type error to a core object: «programElement.debugInfoInContext»''')

		errors.add(exception)
	}

	override reportErrors(ConfigurableDslValidator validator) {
		errors.forEach [
			log.debug('''Reporting error in «programElement.debugInfoInContext»: «message»''')
			try {
				validator.report(message, programElement)
			} catch (IllegalArgumentException exception) {
				log.error(exception.message, exception)
			}
		]

	}

	override getErrorReportTarget() {
		programElement
	}

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	override debugInfo() {
		programElement.debugInfo
	}

	override debugInfoInContext() {
		programElement.debugInfoInContext
	}

}

class ParameterTypeVariableOwner extends TypeVariableOwner {
	TypeVariable parentVariable
	
	String paramName
	
	new(TypeVariable parentVariable, String paramName) {
		this.parentVariable = parentVariable
		this.paramName = paramName
	}
	
	override getURI() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override isCoreObject() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override checkCanBeVoid() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override addError(TypeSystemException exception) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override getErrors() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override reportErrors(ConfigurableDslValidator validator) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override getErrorReportTarget() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override debugInfo() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override debugInfoInContext() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}