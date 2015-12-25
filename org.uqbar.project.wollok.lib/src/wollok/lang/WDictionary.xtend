package wollok.lang

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

/**
 * Native part of the wollok.lang.List class
 * 
 * @author flbulgarelli
 */
class WDictionary implements JavaWrapper<Map> {
	@Accessors var Map wrapped
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess

	new() {
		wrapped = newHashMap
	}

	def size() { wrapped.size }

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

	def boolean containsKey(WollokObject k) {
		wrapped.keySet.findFirst[it.wollokEquals(k)] != null
	}

	def boolean containsValue(WollokObject v) {
		wrapped.values.wollokFind(v) != null
	}

}
