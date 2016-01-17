package org.uqbar.project.wollok.lib

import org.uqbar.project.wollok.interpreter.core.WollokObject
import wollok.lang.Closure

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static org.uqbar.project.wollok.sdk.WollokDSK.*
import wollok.lang.WList
import java.util.List
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

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
	
	def static findConvention(WollokObject it, List<String> conventions) {
		var getter = allMethods.map[it.name].findFirst[isGetter(conventions)]
		if (getter != null)
			return call(getter)

		var attribute = conventions.map[c|instanceVariables.get(c)].filterNull.head
		if (attribute != null)
			return attribute

		throw new WollokRuntimeException(String.format("Visual object doesn't have any position: %s", it.toString))
	}

	def static isGetter(String it, List<String> conventions) {
		conventions.map[#[it, "get" + it.toFirstUpper]].flatten.toList.contains(it)
	}
}