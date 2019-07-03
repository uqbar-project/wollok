package org.uqbar.project.wollok.interpreter

import java.lang.RuntimeException

class WollokTestsFailedException extends RuntimeException {
	
	new() {
		super("Wollok Tests failed exception")
	}

}