package org.uqbar.project.wollok.interpreter.nativeobj

import org.uqbar.project.wollok.ui.utils.XTendUtilExtensions

/**
 * An object that wraps a native object (java/xtend).
 * When you send a message to it, it will try to answer by forwarding
 * the call to the wrapped object, via reflection.
 * 
 * It will try to perform some parameters conversions.
 * 
 * @author jfernandes
 */
class AbstractWollokWrapperNativeObject<T> extends AbstractWollokDeclarativeNativeObject {
	var T wrapped
	
	new(T wrapped) {
		this.wrapped = wrapped
	}
	
	def getWrapped() {
		wrapped
	}
	
	/**
	 * Si no está definido en esta clase como un método "declarativo", buscamos 
	 * en el wrapped
	 */
	override call(String message, Object... parameters) {
		super.call(	message, parameters)
	}
	
	override doesNotUnderstand(String message, Object[] parameters) {
		XTendUtilExtensions.invoke(wrapped, message, parameters)
	}
	
}