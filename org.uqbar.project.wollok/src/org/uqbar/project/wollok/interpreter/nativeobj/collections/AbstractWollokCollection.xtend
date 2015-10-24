package org.uqbar.project.wollok.interpreter.nativeobj.collections

import java.util.Collection
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokWrapperNativeObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import org.uqbar.project.wollok.interpreter.core.WCallable

/**
 * @author jfernandes
 */
abstract class AbstractWollokCollection<T extends Collection> extends AbstractWollokWrapperNativeObject<T> {
	protected WollokInterpreter interpreter
	extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	new(WollokInterpreter interpreter, T nativeList) {	
		super(nativeList)
		this.interpreter = interpreter
	}
	new(WollokInterpreter interpreter, Iterable<Object> nativeList) {
		super(nativeList.toSet as T)	
		this.interpreter = interpreter	
	}
	
	def abstract AbstractWollokCollection<T> asThisCollection(Iterable toWrap)
	
	override equals(Object other) { 
		if (!(other instanceof AbstractWollokCollection)) {
			return false
		}
		val o = other as AbstractWollokCollection
		size == o.size && this.wrapped.forall[e | o.contains(e) ]
	}
	
	def forEach(WollokClosure proc) { wrapped.forEach(proc.asProc) }
	def map(WollokClosure closure) { wrapped.map(closure.asFun).asThisCollection }
	def forAll(WollokClosure pred) { wrapped.forall(pred.asFun) }
	def exists(WollokClosure pred) { wrapped.exists(pred.asFun) }
	def filter(WollokClosure pred) { wrapped.filter(pred.asFun).asThisCollection }
	def detect(WollokClosure pred) { wrapped.findFirst(pred.asFun) }
	def count(WollokClosure pred) { wrapped.filter(pred.asFun).size }
	
	def size() { wrapped.size }
	
	def join() { join(',') }
	def join(String separator) { wrapped.join(separator) }
	
	def Object fold(Object acc, WollokClosure proc) { 
		wrapped.fold(acc)[a,e| proc.apply(a, e)]
	}
	
	def max(WollokClosure closure) { wrapped.maxBy(closure.asFun) }
	def min(WollokClosure closure) { wrapped.minBy(closure.asFun) }
	def Object sum(WollokClosure closure) {
		wrapped.fold(null)[Object a, Object e|
			val r = closure.apply(e)  
			if (a == null) 
				r
			else 
				interpreter.evalBinary(a, '+', r)
		]
	}
	
	def remove(Object o) { 
		// This is necessary because native #contains does not take into account Wollok object equality 
		wrapped.remove(wrapped.findFirst[it.wollokEquals(o)])
	}

	def boolean contains(Object object) { 
		// This is necessary because native #contains does not take into account Wollok object equality 
		wrapped.exists[it.wollokEquals(object)]
	}
	
	def Object any() {
		if (wrapped.isEmpty) throw new WollokRuntimeException("Illegal operation 'any' on empty collection")
		else wrapped.get(randomBetween(0, wrapped.size))
	}
	
	def abstract String getWollokName()
	
	// this is kind of a hack. This should be wollok code once we migrate this "really native" object into a wollok class
	// defined in wollok SDK library
	override toString() { surroundToString(wrapped.map[ if (it instanceof WCallable) call("toString") else toString ].join(", ")) }
	
	def abstract String surroundToString(String s)
}