package wollok.lang

import java.util.Collection
import java.util.Map
import java.util.Map.Entry
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

class WDictionary implements JavaWrapper<Map> {
	
	val WollokObject wollokInstance
	@Accessors var Map wrapped
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess
		 
	new(WollokObject o) {
		wollokInstance = o
		wrapped = newHashMap
	}
	
	def clear() { wrapped.clear }
	
	def get(WollokObject key) { wrapped.get(getInternalKey(key)) }
	
	def put(WollokObject key, WollokObject value) { wrapped.put(key, value) }

	def void remove(WollokObject key) {
		wrapped.remove(getInternalKey(key))
	}
	
	private def Object getInternalKey(WollokObject key) {
		wrapped.keySet.findFirst [ WollokObject itKey |
			itKey.wollokEquals(key)
		]
	}
	
	def keys() {
		convertToList(wrapped.keySet)
	}
	
	def values() { 
		convertToList(wrapped.values) 
	}
	
	def convertToList(Collection _value) {
		_value.map [ it.javaToWollok ].toList
	}
	
	def void forEach(WollokObject proc) {
		wrapped.entrySet.forEach [ Entry entry |
			val c = proc.asClosure
			c.doApply(entry.key.javaToWollok, entry.value.javaToWollok)
		]
   	}
	
}