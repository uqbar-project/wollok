package wollok.lang

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import java.util.HashMap

/**
 * Native part of the wollok.lang.List class
 * 
 * @author flbulgarelli
 */
class WDictionary implements JavaWrapper<Map<WollokObject, WollokObject>> {
	@Accessors var Map<WollokObject, WollokObject> wrapped
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess

	new() {
		wrapped = newHashMap
	}

	def void clear() { wrapped.clear }

	@NativeMessage("equals")
	def wollokEquals(WollokObject other) {
		other.hasNativeType(this.class.name) && (other.getNativeObject(this.class).wrapped == this.wrapped)
	}

	@NativeMessage("==")
	def wollokEqualsEquals(WollokObject other) { wollokEquals(other) }

	def void put(WollokObject k, WollokObject v) { wrapped.put(k, v) }

	def void removeKey(WollokObject k) {
		wrapped.remove(wrapped.keySet.findFirst[it.wollokEquals(k)])
	}
	
	def Object values() {
		wrapped.values().toList
	}
	
	def Object keys() {
		wrapped.keySet()
	}
	
	def Object filter(WollokObject proc) {
		val closure = proc.asClosure
		val dict = newHashMap
		
		wrapped.entrySet.forEach[ 
			if (closure.apply(it.value).wollokToJava(Boolean) as Boolean) {
				dict.put(it.key, it.value)
			}
		]
		
		dict
	}
	
	def Object map(WollokObject proc) {
		val closure = proc.asClosure
		val dict = newHashMap
		wrapped.entrySet.forEach [
			dict.put(it.key, closure.apply(it.value) as WollokObject)
		]
		dict
	}

}
