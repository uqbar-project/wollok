package org.uqbar.project.wollok.ui.debugger.client

import java.lang.RuntimeException

/**
 * Main exception class for all XDebugger.
 * 
 * @author jfernandes
 */
class XDebuggerException extends RuntimeException {
	
	new(String message) {
		super(message)
	}
	
	new(String message, Throwable cause) {
		super(message, cause)
	}
	
}