package wollok.lang

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

/**
 * @author jfernandes
 */
class WInteger extends WNumber<Integer> implements Comparable<WInteger> {
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}
	
	def abs() { Math.abs(wrapped).asWollokObject }
	
	def stringValue() { wrapped.toString }

	@NativeMessage("+")
	def plus(WollokObject other) { operate(other) [ doPlus(it) ] }
		def dispatch Number doPlus(Integer w) { wrapped + w }
		def dispatch Number doPlus(Double w) { wrapped + w }
		//TODO: here it should throw a 100% wollok exception class
		def dispatch Number doPlus(Object w) { throw new WollokRuntimeException("Cannot add " + w) }

	@NativeMessage("-")
	def minus(WollokObject other) { operate(other) [ doMinus(it) ] }
		def dispatch Number doMinus(Integer w) { wrapped - w }
		def dispatch Number doMinus(Double w) { wrapped - w }
		def dispatch Number doMinus(Object w) { throw new WollokRuntimeException("Cannot substract " + w) }

	@NativeMessage("*")
	def multiply(WollokObject other) { operate(other) [ doMultiply(it) ] }
		def dispatch Number doMultiply(Integer w) { wrapped * w }
		def dispatch Number doMultiply(Double w) { wrapped * w }
		def dispatch Number doMultiply(Object w) { throw new WollokRuntimeException("Cannot multiply " + w) }

	@NativeMessage("/")
	def divide(WollokObject other) { operate(other) [ doDivide(it) ] }
		def dispatch Number doDivide(Integer w) { wrapped / w }
		def dispatch Number doDivide(Double w) { wrapped / w }
		def dispatch Number doDivide(Object w) { throw new WollokRuntimeException("Cannot divide " + w) }
		
	@NativeMessage("**")
	def raise(WollokObject other) { operate(other) [ doRaise(it) ] }
		def dispatch Number doRaise(Integer w) { (wrapped ** w).intValue }
		def dispatch Number doRaise(Double w) { wrapped ** w }
		def dispatch Number doRaise(Object w) { throw new WollokRuntimeException("Cannot raise " + w) }

	@NativeMessage("%")
	def module(WollokObject other) { operate(other) [ doModule(it) ] }
		def dispatch Number doModule(Integer w) { wrapped % w }
		def dispatch Number doModule(Double w) { wrapped % w }
		def dispatch Number doModule(Object w) { throw new WollokRuntimeException("Cannot module " + w) }
	
	@NativeMessage(">")
	def greater(WollokObject other) { wrapped.doubleValue > other.nativeNumber.wrapped.doubleValue }
	@NativeMessage(">=")
	def greaterOrEquals(WollokObject other) { wrapped.doubleValue >= other.nativeNumber.wrapped.doubleValue }
	@NativeMessage("<")
	def lesser(WollokObject other) { wrapped.doubleValue < other.nativeNumber.wrapped.doubleValue }
	@NativeMessage("<=")
	def lesserOrEquals(WollokObject other) { wrapped.doubleValue <= other.nativeNumber.wrapped.doubleValue }
	
	def invert() { (-wrapped).asWollokObject }
	
	/// java methods
	
	override equals(Object other) {
		other instanceof WInteger && wrapped == (other as WInteger).wrapped
	}

	override compareTo(WInteger o) { wrapped.compareTo(o.wrapped) }

}