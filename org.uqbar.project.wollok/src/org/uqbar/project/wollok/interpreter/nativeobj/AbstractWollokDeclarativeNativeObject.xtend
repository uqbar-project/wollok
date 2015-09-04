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
		val method = getMethod(toJavaMethod(message), parameters)
		if (method == null)
			doesNotUnderstand(message, parameters).asWollokObject
		else
			try {
				method.invoke(this, parameters).asWollokObject
			} catch (InvocationTargetException e) {
				throw e.cause
			} catch (Throwable e) {
				println(''' Method: «method.name» «method.parameterTypes» Parameters:«parameters.toString» Target:«this» ''')
				e.printStackTrace
				throw e
			}
	}	
	
	def String toJavaMethod(String messageName) {
		if (messageName == "==") "equals"
		else
			messageName
	}

	def getMethod(String message, Object... parameters) {
		var method = this.class.methods.findFirst[handlesMessage(message, parameters)]
		if (method == null)
			method = this.class.methods.findFirst[name == message && parameterTypes.size == parameters.size]
		method
	}

	def isVoid(String message, Object... parameters) {
		val method = getMethod(message, parameters)
		method.returnType == Void.TYPE
	}

	def Object doesNotUnderstand(String message, Object[] objects) {
		throw new MessageNotUnderstood(message)
	}

	def handlesMessage(Method m, String message, Object... parameters) {
		m.isAnnotationPresent(NativeMessage) && m.getAnnotation(NativeMessage).value == message && m.parameterTypes.size == parameters.size
	}

	def <T> T asWollokObject(Object obj) { interpreterAccess.asWollokObject(obj) }

	def identity() { System.identityHashCode(this) }
}
