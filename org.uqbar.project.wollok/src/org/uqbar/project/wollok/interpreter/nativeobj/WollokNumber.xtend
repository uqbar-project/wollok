package org.uqbar.project.wollok.interpreter.nativeobj

/**
 * @deprecated
 */
@Deprecated
abstract class WollokNumber<T extends Number> extends AbstractWollokWrapperNativeObject<T> implements Comparable<WollokNumber<T>> {

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
	
	override equals(Object obj) {
		return this.class.isInstance(obj) && wrapped == (obj as WollokNumber).wrapped 
	}

}

/**
 * @deprecated use WInteger
 */
@Deprecated
class WollokInteger extends WollokNumber<Integer> {
	new(Integer wrapped) {
		super(wrapped)
	}

	override abs() { Math.abs(this.wrapped).asWollokObject }

	override equals(Object other) {
		other instanceof WollokInteger && wrapped == (other as WollokInteger).wrapped
	}

	override compareTo(WollokNumber<Integer> o) {
		this.wrapped.compareTo(o.wrapped)
	}

}

/**
 * @deprecated use WDouble
 */
@Deprecated
class WollokDouble extends WollokNumber<Double> {
	new(Double wrapped) {
		super(wrapped)
	}

	override abs() { Math.abs(this.wrapped).asWollokObject }

	override equals(Object other) {
		other instanceof WollokDouble && wrapped == (other as WollokDouble).wrapped
	}

	override compareTo(WollokNumber<Double> o) {
		this.wrapped.compareTo(o.wrapped)
	}
}
