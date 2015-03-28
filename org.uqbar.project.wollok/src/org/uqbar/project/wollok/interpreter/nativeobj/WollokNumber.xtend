package org.uqbar.project.wollok.interpreter.nativeobj

abstract class WollokNumber<T extends Number> extends AbstractWollokWrapperNativeObject<T> {

	new(T wrapped) {
		super(wrapped)
	}

	// ********************************************************************************************
	// ** Extensions to XTend numbers
	// ********************************************************************************************	

	def max(WollokNumber<?> other) { doMax(this, other).asWollokObject }
	def dispatch doMax(WollokInteger a, WollokInteger b) { Math.max(a.wrapped, b.wrapped) }
	def dispatch doMax(WollokNumber<?> a, WollokNumber<?> b) { Math.max(a.doubleValue, b.doubleValue) }

	def min(WollokNumber<?> other) { doMin(this, other).asWollokObject }
	def dispatch doMin(WollokInteger a, WollokInteger b) { Math.min(a.wrapped, b.wrapped) }
	def dispatch doMin(WollokNumber<?> a, WollokNumber<?> b) { Math.min(a.doubleValue, b.doubleValue) }

	def WollokNumber<?> abs()

	// ********************************************************************************************
	// ** Basics
	// ********************************************************************************************	

	def doubleValue() { wrapped.doubleValue() }
	
	override toString() { wrapped.toString() }	
}

class WollokInteger extends WollokNumber<Integer> {
	new(Integer wrapped) {
		super(wrapped)
	}
	
	override abs() { 
		Math.abs(this.wrapped).asWollokObject
	}
}
	
class WollokDouble extends WollokNumber<Double> {
	new(Double wrapped) {
		super(wrapped)
	}
	override abs() { Math.abs(this.wrapped).asWollokObject }
}
