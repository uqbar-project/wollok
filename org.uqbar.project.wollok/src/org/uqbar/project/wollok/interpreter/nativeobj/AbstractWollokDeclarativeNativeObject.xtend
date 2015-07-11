package org.uqbar.project.wollok.interpreter.nativeobj

import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import org.uqbar.project.wollok.interpreter.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WCallable

/**
 * Abstract base class for all native objects that implements
 * messages as methods.
 * 
 * @see NativeMessage
 * 
 * @author jfernandes
 */
abstract class AbstractWollokDeclarativeNativeObject implements WCallable {
	WollokInterpreterAccess interpreterAccess = new WollokInterpreterAccess

	override call(String message, Object... parameters) {
		val method = getMethod(message, parameters)
		if (method == null)
			doesNotUnderstand(message, parameters).asWollokObject
		else
			try {
				method.invoke(this, parameters).asWollokObject
			}
			catch (InvocationTargetException e) {
				throw e.cause
			}
	}
	
	def getMethod(String message, Object... parameters){
		var method = this.class.methods.findFirst[handlesMessage(message)]
		if (method == null) 
			method = this.class.methods.findFirst[name == message]
		method
	}

	def isVoid(String message, Object... parameters) {
		val method = getMethod(message)
		method.returnType == Void.TYPE
	}
	
	def Object doesNotUnderstand(String message, Object[] objects) {
		throw new MessageNotUnderstood(message)
	}
	
	def handlesMessage(Method m, String message) {
		m.isAnnotationPresent(NativeMessage) && m.getAnnotation(NativeMessage).value == message
	}

	def <T> T asWollokObject(Object obj) { interpreterAccess.asWollokObject(obj) }
	
	def identity() { System.identityHashCode(this) }
}