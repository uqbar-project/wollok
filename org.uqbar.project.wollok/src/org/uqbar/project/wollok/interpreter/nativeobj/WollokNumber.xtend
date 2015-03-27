package org.uqbar.project.wollok.interpreter.nativeobj

abstract class WollokNumber<T extends Number> extends AbstractWollokWrapperNativeObject<T> {
	new(T wrapped) {
		super(wrapped)
	}

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
	
	// ********************************************************************************************
	// ** Binary messages
	// ********************************************************************************************

//	@NativeMessage("+")
//	def sum(Object other) { doSum(other) }
//	def dispatch doSum(WollokInteger other) { wrapped + other.intValue }
//	def dispatch doSum(WollokReal other) { this.realValue + other.realValue }
// 	def dispatch doSum(Object other) { throw new IllegalArgument('''Cannot add «other» to an integer''') }
//
//	@NativeMessage("-")
//	def minus(Object other) { doMinus(other) }
//	def dispatch doMinus(WollokInteger other) { wrapped - other.intValue}
//	def dispatch doMinus(WollokReal other) { this.realValue - other.realValue }
//	def dispatch doMinus(Object other) { throw new IllegalArgument('''Cannot subtract «other» from an integer''')}
//	
//	@NativeMessage("*")
//	def multiply(Object other) { doMultiply(other) }
// 	def dispatch doMultiply(WollokInteger other) { wrapped * other.intValue }
// 	def dispatch doMultiply(WollokReal other) { this.realValue * other.realValue }
//	def dispatch doMultiply(String other) { (1..wrapped).map[other].join }
// 	def dispatch doMultiply(Object other) { throw new IllegalArgument('''Cannot multiply by «other»''') }
//
//	@NativeMessage("/")
//	def divide(Object other) { doDivide(other) }
//	def dispatch doDivide(WollokInteger other) { wrapped / other.intValue }
//	def dispatch doDivide(WollokReal other) { this.realValue / other.realValue }
// 	def dispatch doDivide(Object other) { throw new IllegalArgument('''Cannot divide by «other»''') }
}

class WollokDouble extends WollokNumber<Double> {
	new(Double wrapped) {
		super(wrapped)
	}
		
	// ********************************************************************************************
	// ** Binary messages
	// ********************************************************************************************
	
//	@NativeMessage("+")
//	def sum(Object other) { doSum(other) }
//	def dispatch doSum(WollokNumber<?> other) { wrapped + other.realValue }
// 	def dispatch doSum(Object other) { throw new IllegalArgument('''Cannot add «other» to a real number''') }
//
//	@NativeMessage("-")
//	def minus(Object other) { doMinus(other) }
//	def dispatch doMinus(WollokNumber<?> other) { wrapped - other.realValue }
//	def dispatch doMinus(Object other) { throw new IllegalArgument('''Cannot subtract «other» from an integer''')}
//
//	@NativeMessage("*")
//	def multiply(Object other) { doMultiply(other) }
//	def dispatch doMultiply(WollokNumber<?> other) { wrapped * other.realValue }
// 	def dispatch doMultiply(Object other) { throw new IllegalArgument('''Cannot multiply by «other»''') }
//		
//	@NativeMessage("/")
//	def divide(Object other) { doDivide(other) }
//	def dispatch doDivide(WollokNumber<?> other) { wrapped / other.realValue }
// 	def dispatch doDivide(Object other) { throw new IllegalArgument('''Cannot divide by «other»''') }
}
