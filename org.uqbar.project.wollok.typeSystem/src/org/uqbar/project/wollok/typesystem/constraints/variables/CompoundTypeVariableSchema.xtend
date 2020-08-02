package org.uqbar.project.wollok.typesystem.constraints.variables

import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericTypeSchema
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation

class CompoundTypeVariableSchema extends TypeVariableSchema {
	GenericTypeSchema typeSchema
		
	new(TypeVariableOwner owner, GenericTypeSchema typeSchema) {
		super(owner)
		this.typeSchema = typeSchema
	}
	
 	override getType() {
		WollokType.WAny // TODO
	}
	
	/**
	 * I can have supertypes when I am used as return type for a method. 
	 * The received type variable should be a a message send 
	 * (i.e. {@link WMemberFeatureCall}, {@link WBinaryOperation} or {@link WSuperInvocation}
	 */
	def beSubtypeOf(TypeVariable variable) {
		instanceFor(variable).beSubtypeOf(variable)
	}
	
	/**
	 * I can have subtypes when I am used as parameter type for a method. 
	 * The received type variable should be being used as a parametr to a message send, i.e.
	 * its container should be a message send, 
	 * such as {@link WMemberFeatureCall}, {@link WBinaryOperation} or {@link WSuperInvocation}.
	 */
	def beSupertypeOf(TypeVariable variable) {
		instanceFor(variable).beSupertypeOf(variable)
	}

	// ************************************************************************
	// ** Schema instantiation
	// ************************************************************************
	
	override instanceFor(TypeVariable variable) {
		registry.newSealed(createCompoundOwner, typeSchema.instanceFor(variable))
	}
	
	override instanceFor(ConcreteType concreteReceiver, MessageSend message) {
		registry.newSealed(createCompoundOwner, typeSchema.instanceFor(concreteReceiver, message))
	}

	override toString() '''t(«owner.debugInfoInContext»: «typeSchema»)'''
	
}
