package wollok.lang

import java.math.BigDecimal
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

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
	
	def concat(Object other) { doConcatWith(other) }

	def dispatch WollokObject doConcatWith(WString o) { newInstanceWithWrapped(this.wrapped + o.wrapped) }
	def dispatch WollokObject doConcatWith(WollokObject it) { convertToWString.asWString.doConcatWith }
		
	def startsWith(String prefix) { 
		prefix.checkNotNull("startsWith")
		wrapped.startsWith(prefix)
	}
	
	def endsWith(String suffix) { 
		suffix.checkNotNull("endsWith")
		wrapped.endsWith(suffix)
	}

	def indexOf(String other) { 
		other.checkNotNull("indexOf")
		val result = wrapped.indexOf(other)
		if (result == -1)
			throw new WollokRuntimeException(NLS.bind(Messages.WollokMessage_ELEMENT_NOT_FOUND, other.toString))
		result
	}
	
	def lastIndexOf(String other) { 
		other.checkNotNull("lastIndexOf")
		val result = wrapped.lastIndexOf(other)
		if(result == -1)
			throw new WollokRuntimeException(NLS.bind(Messages.WollokMessage_ELEMENT_NOT_FOUND, other.toString))
		result
	}
	
	def contains(String element) {
		element.checkNotNull("contains")
		wrapped.contains(element)
	}
	
	def toLowerCase() { wrapped.toLowerCase }
	def toUpperCase() { wrapped.toUpperCase }
	def trim() { wrapped.trim }
	def reverse() { new StringBuilder(wrapped).reverse().toString() }
	
	def substring(BigDecimal index) {
		index.checkNotNull("substring")
		wrapped.substring(index.coerceToPositiveInteger)
	}
	
	def substring(BigDecimal startIndex, BigDecimal endIndex) { 
		startIndex.checkNotNull("substring")
		endIndex.checkNotNull("substring")
		wrapped.substring(startIndex.coerceToPositiveInteger, endIndex.coerceToPositiveInteger)
	}
	
	@NativeMessage("toString")
	def wollokToString() { wrapped.toString }

	@NativeMessage("<")
	def lessThan(WollokObject other) {
		other.checkNotNull("<")
		val wString = other.getNativeObject(WString)
		wrapped < wString.wrapped
	}

	@NativeMessage(">")
	def greaterThan(WollokObject other) {
		other.checkNotNull(">")
		val wString = other.getNativeObject(WString)
		wrapped > wString.wrapped
	}

	@NativeMessage("==")
	def wollokEquals(WollokObject other) {
		val wString = other.getNativeObject(WString)
		wString !== null && wrapped == wString.wrapped
	}
	
	def replace(String expression, String replacement) {
		expression.checkNotNull("replace")
		replacement.checkNotNull("replace")
		wrapped.replaceAll(expression, replacement)
	}
	
	def convertToWString(WollokObject it) { call("toString") as WollokObject }

	def asWString(WollokObject it) { 
		val wString = it.getNativeObject(WString)
		if (wString === null) throw new WollokRuntimeException(NLS.bind(Messages.WollokConversion_STRING_CONVERSION_FAILED, it))
		wString
	}
	
}