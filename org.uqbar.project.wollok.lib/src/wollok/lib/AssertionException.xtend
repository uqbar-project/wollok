package wollok.lib

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.eclipse.emf.common.util.URI

/**
 * This exceptions are thrown when an assert is not ok.
 * @author tesonep
 */
@Accessors
class AssertionException extends Exception {

	String message
	WollokObject wollokException
	URI URI
	int lineNumber
	
	new(String message, WollokProgramExceptionWrapper exceptionWrapper) {
		this.message = message
		this.wollokException = exceptionWrapper.wollokException
		this.URI = exceptionWrapper.URI
		this.lineNumber = exceptionWrapper.lineNumber
	}
}
