package org.uqbar.project.wollok.interpreter.nativeobj.collections

import java.util.Set
import org.uqbar.project.wollok.interpreter.WollokInterpreter

/**
 * 
 * @author jfernandes
 */
class WollokSet extends AbstractWollokCollection<Set<Object>> {
	
	new(WollokInterpreter interpreter, Set<Object> nativeSet) {	
		super(interpreter, nativeSet)
	}
	new(WollokInterpreter interpreter, Iterable<Object> nativeSet) {
		super(interpreter, nativeSet.toSet)	
	}
	
	override WollokSet asThisCollection(Iterable toWrap) { new WollokSet(interpreter, toWrap) }

	override clone() { new WollokSet(interpreter, this.wrapped.clone) }

	override getWollokName() { "WSet" }
	
	override surroundToString(String s) { "#{" + s + "}" }
}