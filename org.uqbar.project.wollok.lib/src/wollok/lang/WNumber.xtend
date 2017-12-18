package wollok.lang

import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import org.uqbar.project.wollok.WollokConstants
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
 * @author dodain - 1.6.4 - unification between decimal and integers
 * 
 */
class WNumber extends AbstractJavaWrapper<BigDecimal> {

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
	def plus(BigDecimal other) { 
		wrapped.add(other)
	}

	@NativeMessage("-")
	def minus(BigDecimal other) { 
		wrapped.subtract(other)
	}

	@NativeMessage("*")
	def multiply(BigDecimal other) { 
		wrapped.multiply(other)
	}

	@NativeMessage("/")
	def divide(BigDecimal other) { 
		wrapped.divide(other, RoundingMode.HALF_UP)
	}

	def div(BigDecimal other) { 
		wrapped.divide(other, RoundingMode.HALF_UP).intValue
	}
	
	@NativeMessage("**")
	def raise(BigDecimal other) { 
		Math.pow(wrapped.doubleValue, other.doubleValue)
	}

	@NativeMessage("%")
	def module(BigDecimal other) { 
		wrapped.remainder(other)
	}

	def abs() { this.wrapped.abs.asWollokObject }

	def invert() { (-wrapped).asWollokObject }

	def randomUpTo(WollokObject other) {
		val maximum = other.nativeNumber.wrapped.doubleValue
		val minimum = wrapped.doubleValue()
		((Math.random * (maximum - minimum)) + minimum).doubleValue()
	}

	def roundUp(BigDecimal decimals) {
		scale(decimals, BigDecimal.ROUND_UP)
	}

	def truncate(BigDecimal decimals) {
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

	def gcd(BigDecimal other) {
		val num1 = BigInteger.valueOf(wrapped.coerceToInteger)
		val divisor = other.coerceToInteger
		num1.gcd(BigInteger.valueOf(divisor)).intValue
	}

	def coerceToInteger() {
		wrapped.coerceToInteger
	}

	def isInteger() {
		wrapped.isInteger
	}
	
	/** *******************************************************************
	 * 
	 * INTERNAL METHODS
	 * 
	 * *******************************************************************
	 */
	def scale(BigDecimal _decimals, int operation) {
		// TODO : Wollok exception?
		// TODO : i18n
		val decimals = _decimals.coerceToInteger
		if (decimals < 0) throw new WollokRuntimeException("Cannot set new scale with " + decimals + " decimals")
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
		wrapped.printValueAsString
	}

	// FIXME: Tomarlo de las preferencias
	def decimalPrecision() {
		WollokConstants.DECIMAL_PRECISION
	}
	
}