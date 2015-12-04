package org.uqbar.project.wollok.interpreter.stack

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * We use a java exception to cut the flow when the method evaluates a "return"
 * statement.
 * 
 * @author jfernandes
 */
class ReturnValueException extends RuntimeException {
	@Accessors
	val WollokObject value 
	
	new (WollokObject value){
		this.value = value
	}
}