package wollok.lib

import org.eclipse.xtend.lib.annotations.Accessors

/**
 * This exceptions are thrown when an assert is not ok.
 * @author tesonep
 */
@Accessors
class AssertionException extends Exception {

	@Accessors private String message
	
	new(String message) {
		this.message = message
	}
	
}
