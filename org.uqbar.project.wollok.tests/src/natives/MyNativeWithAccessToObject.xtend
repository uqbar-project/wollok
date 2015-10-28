package natives

import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.WollokInteger
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import wollok.lang.WInteger

/**
 * @author jfernandes
 */
class MyNativeWithAccessToObject {
	val WollokObject obj
	var delta = 100
	
	new(WollokObject obj) {
		this.obj = obj
	}
	
	def lifeMeaning() {
		delta + (obj.resolve("initialValue") as WollokObject).getNativeObject(WInteger).wrapped
	}
	
	def newDelta(Integer newValue) {
		delta = newValue
	}
	
	@NativeMessage("final")
	def finalMethod() { 500 }
	
}