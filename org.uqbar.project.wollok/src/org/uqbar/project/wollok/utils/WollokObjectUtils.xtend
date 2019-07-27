package org.uqbar.project.wollok.utils

import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

import static org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static org.uqbar.project.wollok.sdk.WollokSDK.*

class WollokObjectUtils {

 	/** asString: calls toString for a WollokObject and returns its internal representation */
	def static asString(WollokObject o) {
		o.asString("toString")
	}

	/** calls any method and cast the result to a string */
	def static asString(WollokObject o, String method) {
		(o.call(method).getNativeObject(STRING) as JavaWrapper<String>)?.wrapped
	}
	
	def static checkNotNull(Object o, String operation) {
		if (o === null) {
			throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_NULL_PARAMETER, operation)) 	
		}
	}
	
}
