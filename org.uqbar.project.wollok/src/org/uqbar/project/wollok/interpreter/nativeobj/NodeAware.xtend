package org.uqbar.project.wollok.interpreter.nativeobj

import org.eclipse.emf.ecore.EObject

/**
 * Tells the interpreter that this native object would like to have access
 * to the ast node which triggered its instantiation (for example for literals).
 * 
 * The interpreter will set the ast object
 * 
 * @author jfernandes
 */
interface NodeAware<T extends EObject> {
	
	def void setEObject(T e)
	def T getEObject()
	
}