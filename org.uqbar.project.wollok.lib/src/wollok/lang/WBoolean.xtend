package wollok.lang

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.LazyWollokObject
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

/**
 * 
 * @author jfernandes
 */
class WBoolean extends AbstractJavaWrapper<Boolean> {
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}
	
	@NativeMessage("&&")
	def and(WollokObject lazyOther) { 
		if (!isTrue)
			return false
		else
			return isTrue(lazyOther.apply)
	}
	
	@NativeMessage("||")
	def or(WollokObject lazyOther) { isTrue || isTrue(lazyOther.apply) }
	
	def apply(WollokObject object) { (object as LazyWollokObject).eval }
	
	def isTrue() { wrapped }
	def isFalse() { !wrapped }
	
	def static isTrue(Object it) { it instanceof WollokObject && (it as WollokObject).getNativeObject(WBoolean).wrapped }
	
	@NativeMessage("toString")
	def wollokToString() { wrapped.toString }
	
	@NativeMessage("==")
	def wollokEquals(WollokObject other) {
		val o = other.getNativeObject(WBoolean)
		o !== null && wrapped == o.wrapped
	}
	
	def negate() { ! wrapped }
	
}