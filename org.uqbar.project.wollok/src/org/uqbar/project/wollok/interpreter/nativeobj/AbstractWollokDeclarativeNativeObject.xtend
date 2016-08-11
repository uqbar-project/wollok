package org.uqbar.project.wollok.interpreter.nativeobj

import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Abstract base class for all native objects that implements
 * messages as methods.
 * 
 * @see NativeMessage
 * 
 * @author jfernandes
 */
abstract class AbstractWollokDeclarativeNativeObject implements WCallable {
	WollokObject obj
	@Accessors WollokInterpreter interpreter
	
	new (WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
	}

	override WollokObject call(String message, WollokObject... parameters) {
		val method = getMethod(toJavaMethod(message), parameters)
		if (method == null)
			throw doesNotUnderstand(message, parameters)
		else
			try {
				if (method.parameterTypes.size != parameters.size)
					throw new WollokRuntimeException('''Wrong number of arguments for method. Expected «method.parameterTypes.size» but you passed «parameters.size»''')
				
				method.invokeConvertingArgs(this, parameters)
			}
			catch (WollokProgramExceptionWrapper e) {
				// ok, a java exception was wrapped into a wollok one
				throw e
			}
			catch (IllegalArgumentException e) {
				throw new WollokRuntimeException("Error while calling native java method " + method.shortDescription, e)				
			}
			catch (InvocationTargetException e) {
				throw wrapNativeException(e, method, parameters)
			}
			catch (Throwable e) {
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
		// TODO: cache methods by message (?)
		getMethod(class, message, parameters)
	}
	
	def static getMethod(Class c, String message, Object... parameters) {
		var method = c.methods.findFirst[handlesMessage(message, parameters)]
		if (method == null)
			method = c.methods.findFirst[name == message && matches(parameters)]
		method
	}

	def isVoid(String message, Object... parameters) {
		getMethod(message, parameters).returnType.isVoidType
	}
	
	def static boolean isVoidType(Class<?> it) { it == Void.TYPE || it == void }

	def doesNotUnderstand(String message, Object[] objects) {
		throwMessageNotUnderstood(this, message, objects)
	}
	
	def throwMessageNotUnderstood(Object nativeObject, String name, Object[] parameters) {
		new WollokProgramExceptionWrapper((interpreter.evaluator as WollokInterpreterEvaluator).newInstance(MESSAGE_NOT_UNDERSTOOD_EXCEPTION, nativeObject.createMessage(name, parameters).javaToWollok))
	}

	def static handlesMessage(Method m, String message, Object... parameters) {
		m.isAnnotationPresent(NativeMessage) && m.getAnnotation(NativeMessage).value == message 
			&& m.matches(parameters)
	}
	
	def static matches(Method it, Object... parameters) {
		(parameterTypes.size == parameters.size) || (varArgs && parameters.size >= (parameterTypes.size - 1))
	}

	def <T> T asWollokObject(Object obj) { WollokJavaConversions.javaToWollok(obj) as T}

	def identity() { System.identityHashCode(this) }
	
	def newInstance(Number naitive) {
		(interpreter.evaluator as WollokInterpreterEvaluator).getOrCreateNumber(naitive.toString)
	} 
}
