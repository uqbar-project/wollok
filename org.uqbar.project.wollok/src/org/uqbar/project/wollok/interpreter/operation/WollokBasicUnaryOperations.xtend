package org.uqbar.project.wollok.interpreter.operation

/**
 * An object that provides access to unary operations.
 * Act as an extension provider.
 * 
 * Implementation is decoupled from clients.
 * Allowing to later maybe replace the "native" impl with a
 * more "eat your own dog's food" implementation almost 100% made
 * in Wollok lang itself.
 * 
 * @author tesonep
 */
interface WollokBasicUnaryOperations {
	
	/**
	 * Returns a function (block) that knows how to perform the unary operation.
	 */
	//TODO: object -> WollokObject
	def (Object)=>Object asUnaryOperation(String operationSymbol)
}