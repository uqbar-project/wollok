package wollok.lang

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.WollokNumber

/**
 * 
 * 
 * @author jfernandes
 */
abstract class WNumber<T extends Number> implements JavaWrapper<T> {
	WollokInterpreterAccess interpreterAccess = new WollokInterpreterAccess // re-use a singleton ?
	protected val WollokObject obj
	protected val WollokInterpreter interpreter
	
	@Accessors protected T wrapped
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
	}
	
	def max(WNumber<?> other) { doMax(this, other).asWollokObject }

	def dispatch doMax(WInteger a, WInteger b) { Math.max(a.wrapped, b.wrapped) }

	def dispatch doMax(WNumber<?> a, WNumber<?> b) { Math.max(a.doubleValue, b.doubleValue) }

	def min(WNumber<?> other) { doMin(this, other).asWollokObject }

	def dispatch doMin(WInteger a, WInteger b) { Math.min(a.wrapped, b.wrapped) }

	def dispatch doMin(WNumber<?> a, WNumber<?> b) { Math.min(a.doubleValue, b.doubleValue) }

	def newInstance(Number naitive) {
		(interpreter.evaluator as WollokInterpreterEvaluator).instantiateNumber(naitive.toString)
	} 

	// ********************************************************************************************
	// ** Basics
	// ********************************************************************************************	
	
	def doubleValue() { wrapped.doubleValue() }

	override toString() { wrapped.toString() }
	
	override equals(Object obj) {
		return this.class.isInstance(obj) && wrapped == (obj as WollokNumber).wrapped 
	}
	
	def <T> T asWollokObject(Object obj) { interpreterAccess.asWollokObject(obj) }
	
	def operate(WollokObject other, (Number)=>Number block) {
		val n = other.nativeNumber
		if (n == null)
			throw new WollokRuntimeException("Operation doesn't support parameter " + other)
		val result = block.apply(n.wrapped)
		newInstance(result)
	}
	
	def nativeNumber(WollokObject obj) { obj.getNativeObject(WNumber) }
	
}