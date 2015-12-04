package org.uqbar.project.wollok.lib

import org.uqbar.project.wollok.interpreter.core.WollokObject
import wollok.lang.Closure

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import wollok.lang.WList

/**
 * Extension methods to WollokObject
 * contributed by the SDK.
 * Basically conversions to wdk types
 * 
 * @author jfernandes
 */
class WollokSDKExtensions {
	
	// conversion to natives shortcuts
	
	def static asClosure(WollokObject it) { getNativeObject(CLOSURE) as Closure }
	def static asList(WollokObject it) { getNativeObject(LIST) as WList }
	
}