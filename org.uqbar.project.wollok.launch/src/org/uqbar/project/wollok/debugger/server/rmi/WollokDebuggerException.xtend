package org.uqbar.project.wollok.debugger.server.rmi

/**
 * Base class for remote debugger exceptions
 * 
 * @author jfernandes
 */
class WollokDebuggerException extends RuntimeException {
	
	new(String message, Throwable cause) {
		super(message, cause)
	}
	
}