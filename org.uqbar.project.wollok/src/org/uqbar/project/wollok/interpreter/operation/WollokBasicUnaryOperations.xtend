package org.uqbar.project.wollok.interpreter.operation

import org.uqbar.project.wollok.interpreter.core.WollokObject

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
 * @author jfernandes
 */
interface WollokBasicUnaryOperations {
	
	/**
	 * Returns a function (block) that knows how to perform the unary operation.
	 */
	def (WollokObject)=>WollokObject asUnaryOperation(String operationSymbol)
}