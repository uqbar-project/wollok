package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall

import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

class MessageSend {
	@Accessors(PUBLIC_GETTER)
	TypeVariable receiver

	@Accessors(PUBLIC_GETTER)
	String selector

	@Accessors(PUBLIC_GETTER)
	List<TypeVariable> arguments

	@Accessors(PUBLIC_GETTER)
	TypeVariable returnType

	Map<String, TypeVariable> typeParameters = newHashMap 

	Set<WollokType> openTypes = newHashSet

	new(TypeVariable receiver, String selector, List<TypeVariable> arguments, TypeVariable returnType) {
		this.receiver = receiver
		this.selector = selector
		this.arguments = arguments
		this.returnType = returnType
	}

	// ************************************************************************
	// ** Generic types
	// ************************************************************************
	
	def TypeVariable param(String paramName, () => TypeVariable ifAbsent) {
		typeParameters.getOrElsePut(paramName, ifAbsent)
	}
	
	// ************************************************************************
	// ** Unorganized
	// ************************************************************************
	
	/**
	 * @param type The wollok type which has been recognized as a minimal type for the receiver of this message send, 
	 * 			   and for which we are adding method type information onto this message send.
	 * @return true if the type received is new (not previously added).
	 */
	def addOpenType(WollokType type) {
		openTypes.add(type)
	}

	def fullMessage() {
		returnType.owner.errorReportTarget.fullMessage
	}

	def argumentNames() {
		returnType.owner.errorReportTarget.arguments.map[sourceCode]
	}

	def static dispatch arguments(EObject o) { throw new RuntimeException(NLS.bind(Messages.RuntimeTypeSystemException_ELEMENT_HAS_NO_ARGUMENTS, o)) }

	def static dispatch arguments(WBinaryOperation it) { #[rightOperand] }

	def static dispatch arguments(WMemberFeatureCall it) { memberCallArguments }

	def isClosureMessage() { selector == "apply" }

	def boolean isValid() { !arguments.exists[hasErrors] && !returnType.hasErrors }

	override toString() { returnType.owner.debugInfo }
	
	
}
