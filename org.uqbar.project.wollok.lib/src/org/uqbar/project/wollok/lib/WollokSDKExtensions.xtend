package org.uqbar.project.wollok.lib

import org.uqbar.project.wollok.interpreter.core.WollokObject
import wollok.lang.Closure
import wollok.lang.WList
import wollok.lang.WSet

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * Extension methods to WollokObject
 * contributed by the SDK.
 * Basically conversions to wdk types
 * 
 * @author jfernandes
 */
class WollokSDKExtensions {
	
	// conversion to natives shortcuts
	def static asString(WollokObject it) { wollokToJava(String) as String }
	def static asClosure(WollokObject it) { getNativeObject(CLOSURE) as Closure }
	def static asList(WollokObject it) { getNativeObject(LIST) as WList }
	def static asSet(WollokObject it) { getNativeObject(SET) as WSet }
	
	def static asVisual(WollokObject it) { new WVisual(it) }
	def static asVisualIn(WollokObject it, WollokObject position) { new WVisual(it, position) }

}