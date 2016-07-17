package wollok.lang

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions

/**
 * Base class for numbers.
 * Probably this (int double and number) will be replaced by a BigDecimal.
 * 
 * @author jfernandes
 */
abstract class WNumber<T extends Number> extends AbstractJavaWrapper<T> {

	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}	
	
	def max(WNumber<?> other) { doMax(this, other).asWollokObject }

	def dispatch doMax(WInteger a, WInteger b) { Math.max(a.wrapped, b.wrapped) }

	def dispatch doMax(WNumber<?> a, WNumber<?> b) { Math.max(a.doubleValue, b.doubleValue) }

	def min(WNumber<?> other) { doMin(this, other).asWollokObject }

	def dispatch doMin(WInteger a, WInteger b) { Math.min(a.wrapped, b.wrapped) }

	def dispatch doMin(WNumber<?> a, WNumber<?> b) { Math.min(a.doubleValue, b.doubleValue) }

	def div(WollokObject other) {
		val n = other.nativeNumber
		Math.floor(this.doubleValue / n.doubleValue).intValue
	}

	// ********************************************************************************************
	// ** Basics
	// ********************************************************************************************	
	
	def doubleValue() { wrapped.doubleValue }

	def stringValue() { wrapped.toString }
	
	override toString() { wrapped.toString }
	
	override equals(Object obj) {
		this.class.isInstance(obj) && wrapped == (obj as WNumber).wrapped 
	}
	
	@NativeMessage("===")
	def wollokEquals(WollokObject other) {
		val n = other.nativeNumber
		n != null && n.doubleValue == this.doubleValue
	}
	
	def <T> T asWollokObject(Object obj) { WollokJavaConversions.javaToWollok(obj) as T }
	
	def operate(WollokObject other, (Number)=>Number block) {
		val n = other.nativeNumber
		if (n == null)
			throw new WollokRuntimeException("Operation doesn't support parameter " + other)
		val result = block.apply(n.wrapped)
		newInstance(result)
	}
	
	def newInstance(Number naitive) {
		(interpreter.evaluator as WollokInterpreterEvaluator).getOrCreateNumber(naitive.toString)
	} 
	
	def WNumber<? extends Number> nativeNumber(WollokObject obj) { obj.getNativeObject(WNumber) }
	
}