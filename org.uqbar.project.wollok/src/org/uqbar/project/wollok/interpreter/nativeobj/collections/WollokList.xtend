package org.uqbar.project.wollok.interpreter.nativeobj.collections

import java.util.Collection
import java.util.List
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokWrapperNativeObject

import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * Wrapper for Lists.
 * A Wollok Native List object.
 * 
 * @author jfernandes
 */
class WollokList extends AbstractWollokWrapperNativeObject<List<Object>> {
	WollokInterpreter interpreter

	new(WollokInterpreter interpreter, List<Object> nativeList) {	
		super(nativeList)
		this.interpreter = interpreter
	}
	new(WollokInterpreter interpreter, Iterable<Object> nativeList) {
		super(nativeList.toList)	
		this.interpreter = interpreter	
	}
	
	def void forEach(WollokClosure proc) {	
		wrapped.forEach[proc.apply(it)]
	}
	def boolean forAll(WollokClosure closure) { wrapped.forall[closure.apply(it) as Boolean] }
	def WollokList map(WollokClosure proc) { new WollokList(interpreter, wrapped.map[proc.apply(it)]) }
	def boolean exists(WollokClosure closure) { wrapped.exists[closure.apply(it) as Boolean] }
	def WollokList filter(WollokClosure proc) { new WollokList(interpreter, wrapped.filter[proc.apply(it) as Boolean]) }
	def Object fold(Object acc, WollokClosure proc) { 
		wrapped.fold(acc)[a,e| proc.apply(a, e)]
	}
	def Object max(WollokClosure func) { wrapped.maxBy[e| func.apply(e) as Comparable<?> ]}
	def Object min(WollokClosure func) { wrapped.minBy[e| func.apply(e) as Comparable<?> ]}
	def Object sum(WollokClosure func) {
		wrapped.fold(null)[Object a, Object e|
			val r = func.apply(e)  
			if (a == null) 
				r
			else 
				interpreter.evalBinary(a, '+', r)
		]
	}
	def Object remove(Object o) { wrapped.remove(o) }
	
	def Object detect(WollokClosure pred) { wrapped.findFirst[e| pred.apply(e) as Boolean] }
	def WollokList flatten() {
		val r = newArrayList 
		wrapped.forEach[e| 
			if (e instanceof Collection) r.addAll(e)
			else if (e instanceof WollokList) r.addAll(e.wrapped)
			else r.add(e)
		]
		new WollokList(interpreter, r)
	}
	
	def Object any() {
		if (wrapped.isEmpty)  
			null // ?
		else if (wrapped.size == 1)
			wrapped.get(0)
		else 
			wrapped.get(randomBetween(0, wrapped.size - 1))
	}
	
	def Integer count(WollokClosure predicate) {
		wrapped.filter[predicate.apply(it) as Boolean].size
	}
	
	
	// object
	
	override toString() { "WList" + wrapped.toString }

}