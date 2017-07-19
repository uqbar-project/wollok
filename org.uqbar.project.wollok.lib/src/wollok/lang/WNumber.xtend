package wollok.lang

import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Base class for numbers.
 * 
 * @author jfernandes
 * @author dodain
 */
class WNumber extends AbstractJavaWrapper<BigDecimal> {

	public static int DECIMAL_PRECISION = 5

	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}

	/**
	 * **********************************************************
	 *               BASIC MATHEMATICAL OPERATIONS
	 * **********************************************************
	 */
	def max(WNumber other) {
		this.wrapped.max(other.wrapped).asWollokObject
	}

	def min(WNumber other) {
		this.wrapped.min(other.wrapped).asWollokObject
	}

	@NativeMessage("+")
	def plus(WollokObject other) { operate(other)[doPlus(it)] }

	def dispatch Number doPlus(BigDecimal w) {
		this.add(wrapped, w)
	}

	// TODO: here it should throw a 100% wollok exception class
	def dispatch Number doPlus(Object w) { throw new WollokRuntimeException("Cannot add " + w) }

	@NativeMessage("-")
	def minus(WollokObject other) { operate(other)[doMinus(it)] }

	def dispatch Number doMinus(BigDecimal w) {
		this.subtract(wrapped, w)
	}

	def dispatch Number doMinus(Object w) { throw new WollokRuntimeException("Cannot substract " + w) }

	@NativeMessage("*")
	def multiply(WollokObject other) { operate(other)[doMultiply(it)] }

	def dispatch Number doMultiply(BigDecimal w) {
		this.mul(wrapped, w)
	}

	def dispatch Number doMultiply(Object w) { throw new WollokRuntimeException("Cannot multiply " + w) }

	@NativeMessage("/")
	def divide(WollokObject other) { operate(other)[doDivide(it)] }

	def dispatch Number doDivide(BigDecimal w) {
		this.div(wrapped, w)
	}

	def dispatch Number doDivide(Object w) { throw new WollokRuntimeException("Cannot divide " + w) }

	@NativeMessage("**")
	def raise(WollokObject other) { operate(other)[doRaise(it)] }

	def dispatch Number doRaise(BigDecimal w) { Math.pow(wrapped.doubleValue, w.doubleValue) }

	def dispatch Number doRaise(Object w) { throw new WollokRuntimeException("Cannot raise " + w) }

	@NativeMessage("%")
	def module(WollokObject other) { operate(other)[doModule(it)] }

	def dispatch Number doModule(BigDecimal w) {
		this.remainder(wrapped, w)
	}

	def dispatch Number doModule(Object w) { throw new WollokRuntimeException("Cannot module " + w) }

	def abs() { this.wrapped.abs.asWollokObject }

	def invert() { (-wrapped).asWollokObject }

	def randomUpTo(WollokObject other) {
		val maximum = other.nativeNumber.wrapped.doubleValue
		val minimum = wrapped.doubleValue()
		((Math.random * (maximum - minimum)) + minimum).doubleValue()
	}

	def roundUp(int decimals) {
		scale(decimals, BigDecimal.ROUND_UP)
	}

	def truncate(int decimals) {
		scale(decimals, BigDecimal.ROUND_DOWN)
	}

	@NativeMessage(">")
	def greater(WollokObject other) { wrapped.doubleValue > other.nativeNumber.wrapped.doubleValue }

	@NativeMessage(">=")
	def greaterOrEquals(WollokObject other) { wrapped.doubleValue >= other.nativeNumber.wrapped.doubleValue }

	@NativeMessage("<")
	def lesser(WollokObject other) { wrapped.doubleValue < other.nativeNumber.wrapped.doubleValue }

	@NativeMessage("<=")
	def lesserOrEquals(WollokObject other) { wrapped.doubleValue <= other.nativeNumber.wrapped.doubleValue }

	def gcd(WollokObject other) {
		if (!wrapped.isInteger) {
			throw new IllegalArgumentException("gcd expects receiver to be an integer")
		}
		val num1 = BigInteger.valueOf(wrapped.intValue)
		val divisor = (other.nativeNumber as WNumber).wrapped
		if (!divisor.isInteger) {
			throw new IllegalArgumentException("gcd expects an integer as first argument")
		}
		num1.gcd(BigInteger.valueOf(divisor.intValue)).intValue
	}

	def div(WollokObject other) {
		val n = other.nativeNumber
		Math.floor(this.doubleValue / n.doubleValue).intValue
	}

	/**
	 * **********************************************************************
	 *                INTERNAL MATHEMATICAL OPERATIONS
	 * **********************************************************************
	 */
	def add(BigDecimal sumand1, BigDecimal sumand2) {
		adapt(sumand1).add(sumand2).adapt
	}

	def subtract(BigDecimal minuend, BigDecimal sustraend) {
		adapt(minuend).subtract(sustraend).adapt
	}

	def mul(BigDecimal mul1, BigDecimal mul2) {
		adapt(mul1).multiply(mul2).adapt
	}

	def div(BigDecimal dividend, BigDecimal divisor) {
		adapt(dividend).divide(divisor, RoundingMode.HALF_UP).adapt
	}

	def remainder(BigDecimal dividend, BigDecimal divisor) {
		adapt(dividend).remainder(divisor).adapt
	}

	/** *******************************************************************
	 * 
	 * INTERNAL METHODS
	 * 
	 * *******************************************************************
	 */
	private def adapt(BigDecimal operand) {
		operand.setScale(DECIMAL_PRECISION, BigDecimal.ROUND_HALF_UP)
	}

	def scale(int decimals, int operation) {
		if(decimals < 0) throw new WollokRuntimeException("Cannot set new scale with " + decimals + " decimals")
		wrapped.setScale(decimals, operation)
	}

	def doubleValue() { wrapped.doubleValue }

	override toString() {
		this.stringValue
	}

	override equals(Object obj) {
		this.class.isInstance(obj) && wrapped == (obj as WNumber).wrapped
	}

	@NativeMessage("===")
	def wollokEquals(WollokObject other) {
		val n = other.nativeNumber
		n !== null && n.doubleValue === this.doubleValue
	}

	def <BigDecimal> BigDecimal asWollokObject(Object obj) {
		javaToWollok(obj) as BigDecimal
	}

	def operate(WollokObject other, (Number)=>Number block) {
		val n = other.nativeNumber
		if (n === null)
			throw new WollokRuntimeException("Operation doesn't support parameter " + other)
		val result = block.apply(n.wrapped)
		newInstance(result)
	}

	def newInstance(Number naitive) {
		(interpreter.evaluator as WollokInterpreterEvaluator).getOrCreateNumber(naitive.toString)
	}

	def WNumber nativeNumber(WollokObject obj) { obj.getNativeObject(WNumber) }

	def stringValue() {
		if (wrapped.isInteger) {
			val resultIntValue = wrapped.intValue
			return resultIntValue.toString
		}
		return wrapped.toPlainString
	}

}
