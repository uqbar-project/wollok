package org.uqbar.project.wollok.interpreter.api

import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * Gives access to some interpreter features which are needed to some Wollok objects to work properly.
 */
class WollokInterpreterAccess {
	WollokBasicBinaryOperations operations = new WollokDeclarativeNativeBasicOperations
	
	public static val INSTANCE = new WollokInterpreterAccess
	
	def boolean wollokEquals(WollokObject a, WollokObject b) {
		callBinaryOperation(a, b, EQUALITY)
	}

	def boolean wollokEqualsMethod(WollokObject a, WollokObject b) {
		callBinaryOperation(a, b, "equals")
	}

	def boolean wollokGreaterThan(WollokObject a, WollokObject b) {
		callBinaryOperation(a, b, GREATER_THAN)
	}

	def callBinaryOperation(WollokObject a, WollokObject b, String binaryOperation) {
		operations.asBinaryOperation(binaryOperation).apply(a, [|b]).isTrue
	}

}
