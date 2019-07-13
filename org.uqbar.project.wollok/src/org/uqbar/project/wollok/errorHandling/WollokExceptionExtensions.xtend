package org.uqbar.project.wollok.errorHandling

import java.util.List
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * Extension methods for handling Wollok errors.
 *
 * @author dodain
 */
class WollokExceptionExtensions {

	/**
	 * Factory methods for Wollok well-known exceptions
	 */
	def static messageNotUnderstood(String message) {
		new WollokProgramExceptionWrapper(MESSAGE_NOT_UNDERSTOOD_EXCEPTION.instantiateException(message))
	}
	
	def static throwMessageNotUnderstood(Object nativeObject, String name, Object[] parameters) {
		newException(MESSAGE_NOT_UNDERSTOOD_EXCEPTION, nativeObject.createMessage(name, parameters))
	}
	
	def static WollokProgramExceptionWrapper newException(String exceptionClassName, String message) {
		new WollokProgramExceptionWrapper(exceptionClassName.instantiateException(message))
	}

	def static WollokProgramExceptionWrapper newWollokExceptionAsJava(String message) {
		new WollokProgramExceptionWrapper(newWollokException(message))
	}

	def static instantiateException(String type, String message) {
		getEvaluator.newInstance(type) => [
			setReference("message", message.javaToWollok)
		]
	}
	
	def static WollokObject newWollokException(String message) {
		EXCEPTION.instantiateException(message)
	}

	def static WollokObject newWollokException(String message, WollokObject cause) {
		newWollokException(message) => [
			setReference("cause", cause)
		]
	}

	def static newWollokAssertionException(String message) {
		ASSERTION_EXCEPTION_FQN.instantiateException(message)
	}	

	/** **************************************************************************************************** */

	/**
	 * Converts a StackTraceElementDTO to a List of parseable Strings for a RMI call
	 */
	def static dispatch List<StackTraceElementDTO> convertStackTrace(Throwable e) {
		newArrayList
	}

	def static dispatch List<StackTraceElementDTO> convertStackTrace(WollokProgramExceptionWrapper exception) {
		exception.wollokException.internalStackTraceToDTO
	}

	def static dispatch List<StackTraceElementDTO> convertStackTrace(WollokInterpreterException exception) {
		exception.originalCause.convertStackTrace
	}

	def static dispatch List<StackTraceElementDTO> convertStackTrace(WollokObject wollokException) {
		wollokException.internalStackTraceToDTO
	}

	def static internalStackTraceToDTO(WollokObject fullStackTrace) {
		val stackTrace = fullStackTrace.call("getFullStackTrace").wollokToJava(List) as List<WollokObject>
		val result = newArrayList 
		stackTrace.forEach [ wo |
			val contextDescription = wo.call("contextDescription").wollokToJava(String) as String
			val location = wo.call("location").wollokToJava(String) as String
			val data = location.split(",")
			val fileName = data.get(0)
			var Integer lineNumber = 0
			try {
				lineNumber = new Integer(data.get(1))
			} catch (NumberFormatException e) {
			}
			val newStack = new StackTraceElementDTO(contextDescription, fileName, lineNumber)
			// Unfortunately there are duplicate lines in the stack (because of stack design)
			if (newStack.shouldAppearInStackTrace && !result.contains(newStack)) {
				result.add(newStack)
			}
		]
		result
	}

	/**
	 * Converts an exception to a String
	 */
	def static dispatch String convertToString(WollokProgramExceptionWrapper exception) {
		val wollokException = exception.wollokException
		val className = wollokException.call("className").wollokToJava(String) as String
		val message = exception.wollokMessage
		val concatMessage = if (message !== null) ": " + message else "" 
		return className + concatMessage
	}

	def static dispatch String convertToString(WollokInterpreterException exception) {
		exception.originalCause.convertToString
	}
	
	def static dispatch String convertToString(Exception exception) {
		"ERROR: " + exception.message
	}

	def static dispatch String convertToString(WollokObject exception) {
		exception.call("getStackTrace").wollokToJava(String) as String
	}
	
	/**
	 * Prepares an exception for a RMI call
	 */
	def static dispatch void prepareExceptionForTrip(Throwable e) {
		if (e.cause !== null)
			e.cause.prepareExceptionForTrip
	}

	def static dispatch void prepareExceptionForTrip(WollokInterpreterException e) {
		e.sourceElement = null

		if (e.cause !== null)
			e.cause.prepareExceptionForTrip
	}

	def static dispatch void prepareExceptionForTrip(WollokProgramExceptionWrapper e) {
		e.URI = null
		if (e.cause !== null)
			e.cause.prepareExceptionForTrip
	}

	/**
	 * Determines whether an exception is an AssertionException 
	 */
	def static dispatch boolean isAssertionException(Exception e) {
		isAssertionException(e.class.name)
	}
	
	def static dispatch boolean isAssertionException(WollokProgramExceptionWrapper e) {
		e.wollokException.call("className").toString.isAssertionException
	}
	
	def static dispatch boolean isAssertionException(String className) {
		className.equalsIgnoreCase(ASSERTION_EXCEPTION_FQN)
	}
	
	/**
	 * @dodain - I had to remove previous definition
	 * e.cause instanceof AssertionException
	 * because of project dependencies, so I can reuse this class
	 */
	def static dispatch boolean isAssertionException(WollokInterpreterException e) {
		e.cause.class.name.isAssertionException
	}
	
	/**
	 * Gets current URI
	 */
	def static dispatch getURI(WollokInterpreterException e) {
		e.objectURI
	}
	
	def static dispatch getURI(WollokProgramExceptionWrapper e) {
		e.getURI
	}
	
	def static dispatch getURI(Exception e) {
		throw new IllegalArgumentException(NLS.bind(Messages.WollokInterpreter_assertionExceptionNotValid, e.class.name))
	}
	
	/**
	 * Get current line number
	 */
	def static dispatch getLineNumber(WollokInterpreterException e) {
		e.lineNumber
	}
	
	def static dispatch getLineNumber(WollokProgramExceptionWrapper e) {
		e.lineNumber
	}
	
	def static dispatch getLineNumber(Exception e) {
		throw new IllegalArgumentException(NLS.bind(Messages.WollokInterpreter_assertionExceptionNotValid, e.class.name))
	}
	
	def static String printStackTrace(StackTraceElementDTO[] stackTrace) {
		stackTrace.fold("", [ acum, ste | acum + ste.toLink ])
	}

	def static Throwable originalCause(Throwable e) {
		if (e.cause === null) return e
		e.cause.originalCause
	}
	
	def static String originalMessage(Throwable e) {
		e.originalCause.doOriginalMessage 
	}
	
	def static dispatch doOriginalMessage(WollokProgramExceptionWrapper e) {
		e.wollokMessage
	}
	
	def static dispatch doOriginalMessage(Throwable e) {
		e.message		
	}

	def static dispatch shouldShowStackTraceInJava(WollokProgramExceptionWrapper e) { false }
	def static dispatch shouldShowStackTraceInJava(WollokInterpreterException e) { false }
	def static dispatch shouldShowStackTraceInJava(Throwable t) { true }
	
}
