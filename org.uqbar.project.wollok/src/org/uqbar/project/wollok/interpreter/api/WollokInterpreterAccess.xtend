package org.uqbar.project.wollok.interpreter.api

import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.nativeobj.WollokDouble
import org.uqbar.project.wollok.interpreter.nativeobj.WollokInteger
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations

/**
 * Gives access to some interpreter features which are needed to some Wollok objects to work properly.
 */
class WollokInterpreterAccess {
	WollokBasicBinaryOperations operations = new WollokDeclarativeNativeBasicOperations
	
	/**
	 * Helper method for simple access to wollok equality between objects, 
	 * which is needed in different parts of the interpreter 
	 */
	def boolean wollokEquals(Object a, Object b) {
		operations.asBinaryOperation("==").apply(a, b).isTrue()
	}

	/**
	 * Helper method for simple access to wollok number comparison, 
	 * which is needed in different parts of the interpreter 
	 */
	def boolean wollokGreaterThan(Object a, Object b) {
		operations.asBinaryOperation(">").apply(a, b).isTrue()
	}

	def dispatch boolean isTrue(Boolean b) { b }
	// I18N !
	def dispatch boolean isTrue(Object o) { throw new WollokRuntimeException('''Expected a boolean but find: «o»''') }

	// ********************************************************************************************
	// ** Conversions from native to wollok objects 
	// ********************************************************************************************

	def <T> T asWollokObject(Object object) { object?.doAsWollokObject as T }
	def dispatch doAsWollokObject(Integer i) { new WollokInteger(i) }
	def dispatch doAsWollokObject(Double d) { new WollokDouble(d) }
	def dispatch doAsWollokObject(Object o) { o }
}
