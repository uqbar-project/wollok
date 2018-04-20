package wollok.lang

import java.util.Collection
import java.util.Map
import java.util.Map.Entry
import java.util.TreeMap
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
		wrapped = new TreeMap<WollokObject,WollokObject>(new WollokObjectComparator)
	}
	
	def void clear() { 
		wrapped.clear
	}

	def basicGet(WollokObject key) { 
		wrapped.get(key)
	}
	
	def void put(WollokObject key, WollokObject value) {
		if (key === null) throw new IllegalArgumentException("You cannot put a null key in a Dictionary") 
		if (value === null) throw new IllegalArgumentException("You cannot put a null value in a Dictionary")
		wrapped.put(key, value)
	}

	def void remove(WollokObject key) {
		wrapped.remove(key)
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
		wrapped.entrySet.sortBy [ toString ].forEach [ Entry entry |
			val c = proc.asClosure
			c.doApply(entry.key.javaToWollok, entry.value.javaToWollok)
		]
   	}
	
}