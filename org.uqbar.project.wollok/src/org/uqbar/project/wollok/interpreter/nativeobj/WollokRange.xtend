package org.uqbar.project.wollok.interpreter.nativeobj

import org.uqbar.project.wollok.interpreter.core.WollokClosure

/**
 * Wrapper around integer ranges.
 * Adds forEach and traversable methods.
 * 
 * @author jfernandes
 */
// this is a really draft version
// I think that we should code this in wollok
// for sure we shouldn't use xtend's IntegerRange, since we need to
// use WollokInteger's
class WollokRange extends AbstractWollokWrapperNativeObject<IntegerRange> {
	
	new(IntegerRange wrapped) {
		super(wrapped)
	}
	
	def forEach(WollokClosure proc) { 
		wrapped.forEach[i | proc.apply(new WollokInteger(i)) ]
	}
	
}