package wollok.lang

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

/**
 * Native implementation of the string wollok class
 * 
 * @author jfernandes
 */
class WString extends AbstractJavaWrapper<String> {
	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}

	def length() { wrapped.length }
	
	def charAt(Integer index) {
		wrapped.charAt(index).toString
	}
	
	@NativeMessage("+")
	def concat(Object other) { doConcatWith(other) }
		def dispatch WollokObject doConcatWith(WString o) { newInstanceWithWrapped(this.wrapped + o.wrapped) }
		def dispatch WollokObject doConcatWith(WollokObject it) { convertToWString.asWString.doConcatWith }
		def dispatch WollokObject doConcatWith(Object it) { throw new RuntimeException("Concat doesn't support " + it + " (" + it.class.name + ")") }
		
	def startsWith(WollokObject other) { wrapped.startsWith(other.asWString.wrapped) }
	def endsWith(WollokObject other ) { wrapped.endsWith(other.asWString.wrapped) }
	def indexOf(WollokObject other) { 
		val result = wrapped.indexOf(other.asWString.wrapped)
		if(result == -1)
			throw new WollokRuntimeException("Element not found")
		result
	}
	def lastIndexOf(WollokObject other ){ 
		val result = wrapped.lastIndexOf(other.asWString.wrapped)
		if(result == -1)
			throw new WollokRuntimeException("Element not found")
		result
	} 		
	def contains(WollokObject other) {wrapped.contains(other.asWString.wrapped)}
	def toLowerCase() { wrapped.toLowerCase }
	def toUpperCase() { wrapped.toUpperCase }
	def trim() { wrapped.trim }
	def substring(Integer length) { wrapped.substring(length) }
	def substring(Integer startIndex, Integer length ) { wrapped.substring(startIndex, length) }
	
	@NativeMessage("toString")
	def wollokToString() { wrapped.toString }
	def toSmartString(Object alreadyShown) { wollokToString }

	@NativeMessage("<")
	def lessThan(WollokObject other) {
		val wString = other.getNativeObject(WString)
		wrapped < wString.wrapped
	}

	@NativeMessage(">")
	def greaterThan(WollokObject other) {
		val wString = other.getNativeObject(WString)
		wrapped > wString.wrapped
	}

	@NativeMessage("==")
	def wollokEquals(WollokObject other) {
		val wString = other.getNativeObject(WString)
		wString != null && wrapped == wString.wrapped
	}
	
	def replace(String expression, String replacement) {
		wrapped.replaceAll(expression, replacement)
	}
	
	def convertToWString(WollokObject it) { call("toString") as WollokObject }
	
	def asWString(WollokObject it) { 
		val wString = it.getNativeObject(WString)
		if (wString == null) throw new WollokRuntimeException("Expecting object to be a string: " + it)
		wString
	}
}