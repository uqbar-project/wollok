package org.uqbar.project.wollok.interpreter.context

import org.uqbar.project.wollok.interpreter.WollokRuntimeException

/**
 * @deprecated This must be modeled in wollok itself and it will be replaced by WollokProgramExceptionWrapper
 */
class UnresolvableReference extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}