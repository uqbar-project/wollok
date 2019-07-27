package org.uqbar.project.wollok.interpreter.context

import org.uqbar.project.wollok.interpreter.WollokRuntimeException

/**
 * Unresolvable reference - special exception thrown by interpreter
 */
class UnresolvableReference extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}