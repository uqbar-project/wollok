package org.uqbar.project.wollok.launch.tests

import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import wollok.lib.AssertionException

import static org.uqbar.project.wollok.sdk.WollokSDK.*

class WollokExceptionUtils {

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
		throw new IllegalArgumentException(NLS.bind(Messages.WollokInterpreter_assertionExceptionNotValid, e.class.name))
	}

}
