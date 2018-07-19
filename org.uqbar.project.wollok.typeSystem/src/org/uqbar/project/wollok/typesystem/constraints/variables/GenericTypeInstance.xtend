package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Map
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.MessageType
import org.uqbar.project.wollok.typesystem.WollokType
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Represents an 'instantiated' generic type, i.e. the type of a specific instance of a generic type.
 * For example, if class list is generic and has a type parameter E, a specific list will not have type List<E>.
 * Instead, E should be assigned a specific type, for example [1,2,3] has type List<Number>, 
 * where List<Number> is an instance of the generic type List<E>.
 * 
 * This is an implementation type, specific to the constraint based type system, as the type information for 
 * the instantiated type parameters is represented by type variables and not by regular Wollok types.
 * 
 * @author npasserini
 */
class GenericTypeInstance implements ConcreteType {
	@Accessors(PUBLIC_GETTER)
	GenericType rawType
	
	@Accessors(PUBLIC_GETTER)
	Map<String, TypeVariable> typeParameters
	
	new(GenericType type, Map<String, TypeVariable> typeParameters) {
		this.rawType = type
		this.typeParameters = typeParameters
	}

	def param(String paramName) {
		typeParameters.get(paramName)	
	}
	
	def baseType() {
		rawType.baseType
	}

	// ************************************************************************
	// ** Interface WollokType, mostly delegated to the rawType itself
	// ************************************************************************
	
	override getName() {
		baseType.name
	}
	
	override getContainer() {
		baseType.container
	}
	
	override getTypeSystem() {
		baseType.typeSystem
	}

	override acceptsAssignment(WollokType other) {
		baseType.acceptsAssignment(other)
	}
	
	override acceptAssignment(WollokType other) {
		baseType.acceptAssignment(other)
	}
	
	override understandsMessage(MessageType message) {
		baseType.understandsMessage(message)
	}
	
	override resolveReturnType(MessageType message) {
		baseType.resolveReturnType(message)
	}
	
	override refine(WollokType previouslyInferred) {
		baseType.refine(previouslyInferred)
	}
	
	override getAllMessages() {
		baseType.allMessages
	}
	
	override lookupMethod(MessageType message) {
		baseType.lookupMethod(message)
	}
	
	override lookupMethod(String selector, List<?> parameterTypes) {
		baseType.lookupMethod(selector, parameterTypes)
	}		

	// ************************************************************************
	// ** Basics
	// ************************************************************************
	
	override toString() { rawType.toString(this).toString }
	
	def dispatch equals(Object other ) { false }
	def dispatch equals(GenericTypeInstance other) { rawType == other.rawType }
	
}