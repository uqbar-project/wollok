package org.uqbar.project.wollok.interpreter.api

import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations

/**
 * Gives access to some interpreter features which are needed to some Wollok objects to work properly.
 */
class WollokInterpreterAccess {
	extension WollokBasicBinaryOperations = new WollokDeclarativeNativeBasicOperations
	
	/**
	 * Helper method for simple access to wollok equality between objects, 
	 * which is needed in different parts of the interpreter 
	 */
	def boolean wollokEquals(Object a, Object b) {
		"==".asBinaryOperation.apply(a, b).isTrue()
	}

	def dispatch boolean isTrue(Boolean b) { b }
	def dispatch boolean isTrue(Object o) { throw new WollokRuntimeException('''Expected a boolean but find: «o»''') }
}
