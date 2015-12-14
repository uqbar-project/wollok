package org.uqbar.project.wollok.interpreter

/**
 * Superclass for all exceptions that the wollok interpreter can throw while evaluating a program.
 * 
 * @author jfernandes
 */
class WollokRuntimeException extends RuntimeException {
	new(String message) {
		super(message)
	}	
	new(String message, Throwable t) {
		super(message, t)
	}
}

/**
 * @deprecated This must be modeled in wollok itself and it will be replaced by WollokProgramExceptionWrapper
 */
class UnresolvableReference extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}

class IllegalBinaryOperation extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}
