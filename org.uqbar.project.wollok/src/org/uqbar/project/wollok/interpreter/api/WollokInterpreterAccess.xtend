package org.uqbar.project.wollok.interpreter.api

import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Gives access to some interpreter features which are needed to some Wollok objects to work properly.
 */
class WollokInterpreterAccess {
	WollokBasicBinaryOperations operations = new WollokDeclarativeNativeBasicOperations
	
	public static val INSTANCE = new WollokInterpreterAccess
	
	/**
	 * Helper method for simple access to wollok equality between objects, 
	 * which is needed in different parts of the interpreter 
	 */
	def boolean wollokEquals(WollokObject a, WollokObject b) {
		operations.asBinaryOperation("==").apply(a, [|b]).isTrue
	}

	/**
	 * Helper method for simple access to wollok number comparison, 
	 * which is needed in different parts of the interpreter 
	 */
	def boolean wollokGreaterThan(WollokObject a, WollokObject b) {
		operations.asBinaryOperation(">").apply(a, [|b]).isTrue
	}

}
