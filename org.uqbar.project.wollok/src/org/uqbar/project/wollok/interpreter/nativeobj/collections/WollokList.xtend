package org.uqbar.project.wollok.interpreter.nativeobj.collections

import java.util.List
import org.uqbar.project.wollok.interpreter.WollokInterpreter

/**
 * Wrapper for Lists.
 * A Wollok Native List object.
 * 
 * @author jfernandes
 * @author npasserini
 */
class WollokList extends AbstractWollokCollection<List<Object>> {

	new(WollokInterpreter interpreter, List<Object> nativeList) {	
		super(interpreter, nativeList)
	}
	new(WollokInterpreter interpreter, Iterable<Object> nativeList) {
		super(interpreter, nativeList.toList)	
	}

	// This method should be merged with the #asWollokObject methods in the superclass, 
	// but it requires access to the interpreter which we only have here.
	override WollokList asThisCollection(Iterable toWrap) { new WollokList(interpreter, toWrap) }	

	/**
	 * Multiple level flattenning. Nulls removed.
	 */		
	def WollokList flatten() { newArrayList.asThisCollection.addFlat(this) }
	def dispatch WollokList addFlat(WollokList accum, WollokList elem) { elem.wrapped.forEach[accum.addFlat(it)]; accum}
	def dispatch addFlat(WollokList accum, Object elem) { accum.wrapped.add(elem); accum }
	def dispatch addFlat(WollokList accum, Void elem) { accum }
	
	override clone() { new WollokList(interpreter, this.wrapped.clone) }
	
	override getWollokName() {
		"WList"
	}
	
	override surroundToString(String s) { "#[" + s + "]"}
	
}