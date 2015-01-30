package org.uqbar.project.wollok.semantics

import java.lang.RuntimeException

/**
 * @author jfernandes
 */
class TypeSystemException extends RuntimeException {
	new() {
	}
	
	new(String message) {
		super(message)
	}
}