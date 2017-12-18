package natives

import java.math.BigDecimal
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import wollok.lang.WNumber

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

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
		delta + (obj.resolve("initialValue") as WollokObject).getNativeObject(WNumber).wrapped.intValue
	}
	
	def newDelta(BigDecimal newValue) {
		delta = newValue.coerceToInteger
	}
	
	@NativeMessage("final")
	def finalMethod() { 500 }
	
}