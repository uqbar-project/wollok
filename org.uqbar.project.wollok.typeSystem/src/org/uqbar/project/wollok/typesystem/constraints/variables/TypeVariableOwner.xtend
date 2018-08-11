package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.exceptions.CannotBeVoidException
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.isReferenceTo
import static extension org.uqbar.project.wollok.scoping.WollokResourceCache.isCoreObject
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo.canBeVoid

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

	List<TypeSystemException> errors = newArrayList

	// ************************************************************************
	// ** Information
	// ************************************************************************
	def URI getURI()

	def boolean isCoreObject()

	def void checkCanBeVoid()

	// ************************************************************************
	// ** Error handling
	// ************************************************************************
	def addError(TypeSystemException exception) {
		if (isCoreObject)

			throw new RuntimeException(NLS.bind(Messages.RuntimeTypeSystemException_TRIED_TO_ADD_ERROR_TO_CORE_OBJECT, debugInfoInContext))

		errors.add(exception)
	}

	def hasErrors() {
		!this.errors.empty
	}

	def reportErrors(ConfigurableDslValidator validator) {
		errors.forEach [
			log.debug('''Reporting error in «debugInfoInContext»: «message»''')
			try {
				validator.report(message, errorReportTarget)
			} catch (IllegalArgumentException exception) {
				log.error(exception.message, exception)
			}
		]

	}


	def EObject getErrorReportTarget()

	// ************************************************************************
	// ** Model information
	// ************************************************************************

	def isReferenceTo(TypeVariableOwner ref) {
		errorReportTarget.isReferenceTo(ref.errorReportTarget)
	}
	

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	def String debugInfo()

	def String debugInfoInContext()

	override toString() { debugInfoInContext }	

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

	new(EObject programElement) {
		if(programElement === null) 
			throw new IllegalArgumentException(NLS.bind(Messages.RuntimeTypeSystemException_REQUIRES_PROGRAM_ELEMENT, class.simpleName))
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
	@Accessors(PUBLIC_GETTER)
	TypeVariableOwner parent
	
	String paramName
	
	new(TypeVariableOwner parent, String paramName) {
		this.parent = parent
		this.paramName = paramName
	}
	
	override getURI() {
		// Warning: the generated URI is very unintuitive, but it is easy and provides uniqueness.
		// TODO: Replace by a more legible implementation when this fails short.
		parent.URI.appendSegment(paramName)
	}
	
	override isCoreObject() {
		parent.isCoreObject
	}
	
	override checkCanBeVoid() {
		// Do nothing, allways allow true (TODO sure?)
	}
	
	override getErrorReportTarget() {
		parent.errorReportTarget
	}
	
	override debugInfo() '''tparam «paramName» of «parent.debugInfo»'''
	
	override debugInfoInContext() '''tparam «paramName» of «parent.debugInfoInContext»'''
}