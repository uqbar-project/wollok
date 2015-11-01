package org.uqbar.project.wollok.interpreter.operation

/**
 * An object that provides access to binary operations.
 * Act as an extension provider.
 * 
 * Implementation is decoupled from clients.
 * Allowing to later maybe replace the "native" impl with a
 * more "eat your own dog's food" implementation almost 100% made
 * in Wollok lang itself.
 * 
 * @author jfernandes
 */
interface WollokBasicBinaryOperations {
	
	/**
	 * Returns a function (block) that knows how to perform the binary operation.
	 */
	//TODO: after removing all 100% java objects this return type will have type WollokObject instead of Object
	def (Object, ()=>Object)=>Object asBinaryOperation(String operationSymbol)
}