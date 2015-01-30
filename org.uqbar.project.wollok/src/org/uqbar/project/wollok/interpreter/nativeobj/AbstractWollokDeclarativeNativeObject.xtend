package org.uqbar.project.wollok.interpreter.nativeobj

import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import org.uqbar.project.wollok.interpreter.context.MessageNotUnderstood
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

	override call(String message, Object... parameters) {
		var method = this.class.methods.findFirst[name == message]
		if (method == null) 
			method = this.class.methods.findFirst[handlesMessage(message)]
		if (method == null)
			return doesNotUnderstand(message, parameters)
		else
			try {
				method.invoke(this, parameters)
			}
			catch (InvocationTargetException e) {
				throw e.cause
			}
	}
	
	def Object doesNotUnderstand(String message, Object[] objects) {
		throw new MessageNotUnderstood(message)
	}
	
	def handlesMessage(Method m, String message) {
		m.isAnnotationPresent(NativeMessage) && m.getAnnotation(NativeMessage).value == message
	}

}