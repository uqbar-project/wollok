package org.uqbar.project.wollok.interpreter.nativeobj.collections

import java.util.List
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokWrapperNativeObject

import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * Wrapper for Lists.
 * A Wollok Native List object.
 * 
 * @author jfernandes
 * @author npasserini
 */
class WollokList extends AbstractWollokWrapperNativeObject<List<Object>> {
	WollokInterpreter interpreter
	extension WollokInterpreterAccess = new WollokInterpreterAccess

	new(WollokInterpreter interpreter, List<Object> nativeList) {	
		super(nativeList)
		this.interpreter = interpreter
	}
	new(WollokInterpreter interpreter, Iterable<Object> nativeList) {
		super(nativeList.toList)	
		this.interpreter = interpreter	
	}

	// This method should be merged with the #asWollokObject methods in the superclass, 
	// but it requires access to the interpreter which we only have here.	
	def asWList(Iterable<Object> nativeList) { new WollokList(interpreter, nativeList) }

	// If this two methods were modelled as automatic coercions, many of the list methods below
	// could be eliminated an delegated to the wrapped list.
	def <Input, Output> asFun(WollokClosure closure) { [closure.apply(it as Input) as Output] }
	def <Input> Procedure1<Input> asProc(WollokClosure proc) { [proc.apply(it as Input)] }
	
	def forEach(WollokClosure proc) { wrapped.forEach(proc.asProc) }
	def map(WollokClosure closure) { wrapped.map(closure.asFun).asWList }
	def forAll(WollokClosure pred) { wrapped.forall(pred.asFun) }
	def exists(WollokClosure pred) { wrapped.exists(pred.asFun) }
	def filter(WollokClosure pred) { wrapped.filter(pred.asFun).asWList }
	def detect(WollokClosure pred) { wrapped.findFirst(pred.asFun) }
	def count(WollokClosure pred) { wrapped.filter(pred.asFun).size }
	
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
	
	/**
	 * Multiple level flattenning. Nulls removed.
	 */		
	def WollokList flatten() { newArrayList.asWList.addFlat(this) }
	def dispatch WollokList addFlat(WollokList accum, WollokList elem) { elem.wrapped.forEach[accum.addFlat(it)]; accum}
	def dispatch addFlat(WollokList accum, Object elem) { accum.wrapped.add(elem); accum }
	def dispatch addFlat(WollokList accum, Void elem) { accum }
	
	def Object any() {
		if (wrapped.isEmpty) throw new WollokRuntimeException("Illegal operation 'any' on empty list")
		else wrapped.get(randomBetween(0, wrapped.size - 1))
	}
	
	// object
	override toString() { "WList" + wrapped.toString }
	
	override clone() { new WollokList(interpreter, this.wrapped.clone) }

}