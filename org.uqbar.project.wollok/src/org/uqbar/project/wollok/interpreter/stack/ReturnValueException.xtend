package org.uqbar.project.wollok.interpreter.stack

import java.lang.RuntimeException
import org.eclipse.xtend.lib.annotations.Accessors

class ReturnValueException extends RuntimeException {
	@Accessors
	val Object value 
	
	new (Object value){
		this.value = value
	}
}