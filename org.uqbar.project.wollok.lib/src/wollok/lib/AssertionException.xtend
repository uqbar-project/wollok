package wollok.lib

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * This exceptions are thrown when an assert is not ok.
 * @author tesonep
 */
@Accessors
class AssertionException extends Exception {

	private String message
	private WollokObject wollokException
	
	new(String message) {
		this.message = message
	}
	
	new(String message, WollokObject wollokException) {
		this.message = message
		this.wollokException = wollokException
	}
}
