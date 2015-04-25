package org.uqbar.project.wollok.interpreter.nativeobj

import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * An object that wraps a native object (java/xtend).
 * When you send a message to it, it will try to answer by forwarding
 * the call to the wrapped object, via reflection.
 * 
 * It will try to perform some parameters conversions (maybe in the future?)
 * 
 * @author jfernandes
 */
class AbstractWollokWrapperNativeObject<T> extends AbstractWollokDeclarativeNativeObject {
	var T wrapped
	
	new(T wrapped) {
		this.wrapped = wrapped
	}
	
	def getWrapped() { wrapped }
		
	/**
	 * If a message is not defined declaratively, delegate on the native wrapped object.
	 */
	override doesNotUnderstand(String message, Object[] parameters) {
		wrapped.invoke(message, parameters)
	}
	
}