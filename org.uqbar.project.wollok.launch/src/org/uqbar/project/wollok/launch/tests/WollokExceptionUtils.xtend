package org.uqbar.project.wollok.launch.tests

import java.io.PrintWriter
import java.io.StringWriter
import java.util.List
import org.uqbar.project.wollok.errorHandling.StackTraceElementDTO
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import wollok.lib.AssertionException

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*

class WollokExceptionUtils {


	/**
	 * Converts a StackTraceElementDTO to a List of parseable Strings for a RMI call
	 */
	def static dispatch List<StackTraceElementDTO> convertStackTrace(Exception exception) {
		newArrayList
	}

	def static dispatch List<StackTraceElementDTO> convertStackTrace(WollokProgramExceptionWrapper exception) {
		exception.wollokException.internalStackTraceToDTO
	}

	def static dispatch List<StackTraceElementDTO> convertStackTrace(WollokObject wollokException) {
		wollokException.internalStackTraceToDTO
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
		return "ERROR: " + exception.originalCause.message
	}

	def static Throwable originalCause(Throwable e) {
		if (e.cause === null) return e
		e.cause.originalCause
	}
	
	def static dispatch String convertToString(Exception exception) {
		val sw = new StringWriter
		exception.printStackTrace(new PrintWriter(sw))
		sw.toString
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
	def static dispatch isAssertionException(Exception e) {
		false
	}
	
	def static dispatch isAssertionException(AssertionException e) {
		true
	}
	
	def static dispatch isAssertionException(WollokProgramExceptionWrapper e) {
		val className = e.wollokException.call("className").toString
		className.equalsIgnoreCase(ASSERTION_EXCEPTION_FQN)
	}
	
	def static dispatch isAssertionException(WollokInterpreterException e) {
		e.cause instanceof AssertionException
	}
	
	/**
	 * Generates an assertion error when necessary
	 */
	def static dispatch generateAssertionError(WollokInterpreterException e) {
		e.cause as AssertionException
	}
	
	def static dispatch generateAssertionError(WollokProgramExceptionWrapper e) {
		new AssertionException(e.wollokMessage, e)
	}

	def static dispatch generateAssertionError(Exception e) {
		throw new IllegalArgumentException(e.class.name + " is not a valid AssertionException")
	}

	/**
	 * Gets current URI
	 */
	def static dispatch getURI(WollokInterpreterException e) {
		e.objectURI
	}
	
	def static dispatch getURI(WollokProgramExceptionWrapper e) {
		e.URI
	}
	
	def static dispatch getURI(Exception e) {
		throw new IllegalArgumentException(e.class.name + " is not a valid AssertionException")
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
		throw new IllegalArgumentException(e.class.name + " is not a valid AssertionException")
	}
}
