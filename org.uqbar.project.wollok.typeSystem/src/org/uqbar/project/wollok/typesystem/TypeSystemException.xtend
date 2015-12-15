package org.uqbar.project.wollok.typesystem

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