package wollok.lang

import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokClosure

/**
 * Native part of the wollok.lang.WList class
 * 
 * @author jfernandes
 */
class WList {
	val wrapped = newArrayList
	extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	def Object fold(Object acc, WollokClosure proc) {
		wrapped.fold(acc) [i, e|
			proc.apply(i, e)
		]
	}
	
	def void add(Object e) { wrapped.add(e) }
	def void remove(Object e) { 
		// This is necessary because native #contains does not take into account Wollok object equality 
		wrapped.remove(wrapped.findFirst[it.wollokEquals(e)])
	}
	def size() { wrapped.size.asWollokObject }
	
	def get(int index) { wrapped.get(index) }
	
	def void clear() { wrapped.clear }
	
	def join(String separator) {
		wrapped.map[ if (it instanceof WCallable) call("toString") else toString ].join(", ")
	}
	
}