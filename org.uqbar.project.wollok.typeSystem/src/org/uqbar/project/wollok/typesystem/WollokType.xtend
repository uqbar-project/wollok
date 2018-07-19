package org.uqbar.project.wollok.typesystem

import java.util.Iterator
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

/**
 * 
 * @author npasserini
 * @author jfernandes
 */
interface WollokType {

	// ************************************************************************
	// ** Basic types
	// ************************************************************************
	public static val WVoid = new VoidType
	public static val WAny = new AnyType
	
	def String getName() 

	// ************************************************************************
	// ** Interface
	// ************************************************************************

	def boolean acceptsAssignment(WollokType other)

	/**
	 * Very similar to {@link acceptsAssignment} but throws exception instead of returning a boolean
	 */
	def void acceptAssignment(WollokType other)
	
	def boolean understandsMessage(MessageType message)
	
	def WollokType resolveReturnType(MessageType message)

	/** 
	 * This type was found while inferring a type.
	 * So it has the opportunity to refine the type.
	 * If he founds that they are not compatible at all, then it could fail
	 * throwing TypeSystemException which will cause a type check error.
	 */
	def WollokType refine(WollokType previouslyInferred)
	
	/**
	 * Returns all messages that this types defines.
	 * This is useful for content assist, for example.
	 */
	def Iterable<MessageType> getAllMessages()
	
	def WollokType instanceFor(TypeVariable variable)
}


/**
 * Utilities around type system
 * 
 * @author jfernandes
 */
// Nombre desactualizado
class TypeInferrer {
	
	def static structuralType(Iterable<MessageType> messagesTypes) {
		structuralType(messagesTypes.iterator)
	}
	
	def static structuralType(Iterator<MessageType> messagesTypes) {
		new StructuralType(messagesTypes)	
	}
	
}