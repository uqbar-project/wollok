package org.uqbar.project.wollok.interpreter.nativeobj

/**
 * Interface for native classes which actually wrap a java native object.
 * For example our WNumber wollok class has a WNumber java class native impl
 * which in turns has the real value java.math.BigDecimal there.
 * 
 * @author jfernandes
 */
interface JavaWrapper<T> {
	def T getWrapped()
	def void setWrapped(T t)
}