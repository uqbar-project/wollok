package org.uqbar.project.wollok.interpreter.operation

import org.uqbar.project.wollok.interpreter.core.WollokObject

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
	def (WollokObject, ()=>WollokObject)=>WollokObject asBinaryOperation(String operationSymbol)
}