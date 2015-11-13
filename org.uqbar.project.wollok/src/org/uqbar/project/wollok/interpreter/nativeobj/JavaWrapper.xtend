package org.uqbar.project.wollok.interpreter.nativeobj

/**
 * Interface for native classes which actually wrap a java native object.
 * For example our WInteger wollok class has a WInteger java class native impl
 * which in turns has the real value java.lang.Integer there.
 * 
 * @author jfernandes
 */
interface JavaWrapper<T> {
	def T getWrapped()
	def void setWrapped(T t)
}