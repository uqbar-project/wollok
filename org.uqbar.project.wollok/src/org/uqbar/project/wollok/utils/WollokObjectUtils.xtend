package org.uqbar.project.wollok.utils

import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import static extension org.uqbar.project.wollok.sdk.WollokDSK.* 

class WollokObjectUtils {

 	/** asString: calls toString for a WollokObject and returns its internal representation */
	def static asString(WollokObject o) {
		((o.call("toString") as WollokObject).getNativeObject(STRING) as JavaWrapper<String>)?.wrapped
	}

	/** calls any method and cast the result to a string */
	def static asString(WollokObject o, String method) {
		((o.call(method) as WollokObject).getNativeObject(STRING) as JavaWrapper<String>)?.wrapped
	}
	
}
