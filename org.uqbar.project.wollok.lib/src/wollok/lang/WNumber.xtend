package wollok.lang

import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.interpreter.nativeobj.WollokNumbersPreferences

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
	def div(BigDecimal other) { 
		other.checkNotNull("div")
		wrapped.divide(other, RoundingMode.HALF_UP).intValue
	}

	@NativeMessage("+")
	def plus(WollokObject other) { 
		other.checkNotNull("+")
		operate(other)[doPlus(it)]
	}

	def dispatch Number doPlus(BigDecimal w) {
		this.add(wrapped, w)
	}

	def dispatch Number doPlus(Object w) { 
		throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_PARAMETER, w))
	}

	@NativeMessage("-")
	def minus(WollokObject other) { 
		other.checkNotNull("-")
		operate(other)[doMinus(it)]
	}

	def dispatch Number doMinus(BigDecimal w) {
		this.subtract(wrapped, w)
	}

	def dispatch Number doMinus(Object w) { 
		throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_PARAMETER, w))
	}

	@NativeMessage("*")
	def multiply(WollokObject other) { 
		other.checkNotNull("*")
		operate(other)[doMultiply(it)]
	}

	def dispatch Number doMultiply(BigDecimal w) {
		this.mul(wrapped, w)
	}

	def dispatch Number doMultiply(Object w) { 
		throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_PARAMETER, w))
	}

	@NativeMessage("/")
	def divide(WollokObject other) { 
		other.checkNotNull("/")
		operate(other)[doDivide(it)]
	}

	def dispatch Number doDivide(BigDecimal w) {
		this.div(wrapped, w)
	}

	def dispatch Number doDivide(Object w) { 
		throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_PARAMETER, w))
	}

	@NativeMessage("**")
	def raise(WollokObject other) { 
		other.checkNotNull("**")
		operate(other)[doRaise(it)]
	}

	def dispatch Number doRaise(BigDecimal w) { 
		Math.pow(wrapped.doubleValue, w.doubleValue)
	}

	def dispatch Number doRaise(Object w) { 
		throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_PARAMETER, w))
	}

	@NativeMessage("%")
	def module(WollokObject other) { 
		other.checkNotNull("%")
		operate(other)[doModule(it)]
	}

	def dispatch Number doModule(BigDecimal w) {
		this.remainder(wrapped, w)
	}

	def dispatch Number doModule(Object w) { 
		throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_PARAMETER, w))
	}
	
	def abs() { this.wrapped.abs.asWollokObject }

	def invert() { (-wrapped).asWollokObject }

	def randomUpTo(BigDecimal other) {
		other.checkNotNull("randomUpTo")
		val maximum = other.doubleValue
		val minimum = wrapped.doubleValue
		return (Math.random * (maximum - minimum) + minimum).doubleValue
	}

	def roundUp(BigDecimal decimals) {
		decimals.checkNotNull("roundUp")
		scale(decimals, BigDecimal.ROUND_UP)
	}

	def truncate(BigDecimal decimals) {
		decimals.checkNotNull("truncate")
		scale(decimals, BigDecimal.ROUND_DOWN)
	}

	@NativeMessage(">")
	def greater(BigDecimal other) { 
		other.checkNotNull(">")
		wrapped.doubleValue > other.doubleValue
	}

	@NativeMessage("<")
	def lesser(BigDecimal other) { 
		other.checkNotNull("<")
		wrapped.doubleValue < other.doubleValue
	}

	def gcd(BigDecimal other) {
		other.checkNotNull("gcd")
		val num1 = BigInteger.valueOf(wrapped.coerceToInteger)
		val divisor = other.coerceToInteger
		num1.gcd(BigInteger.valueOf(divisor)).intValue
	}

	def coerceToPositiveInteger() {
		wrapped.coerceToPositiveInteger
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
		val decimals = _decimals.coerceToInteger
		if (decimals < 0) throw throwInvalidOperation(Messages.WollokConversion_INVALID_SCALE_NUMBER)
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

	def newInstance(Number naitive) {
		(interpreter.evaluator as WollokInterpreterEvaluator).getOrCreateNumber(naitive.toString)
	}

	def WNumber nativeNumber(WollokObject obj) { obj.getNativeObject(WNumber) }

	def stringValue() {
		wrapped.printValueAsString
	}

	def decimalPrecision() {
		WollokNumbersPreferences.instance.decimalPositions
	}

	/**
	 * **********************************************************************
	 *                INTERNAL MATHEMATICAL OPERATIONS
	 * **********************************************************************
	 */
	def add(BigDecimal sumand1, BigDecimal sumand2) {
		sumand1.add(sumand2)
	}

	def subtract(BigDecimal minuend, BigDecimal sustraend) {
		minuend.subtract(sustraend)
	}

	def mul(BigDecimal mul1, BigDecimal mul2) {
		mul1.multiply(mul2).stripTrailingZeros.adaptResult
	}

	def div(BigDecimal dividend, BigDecimal divisor) {
		dividend.divide(divisor, RoundingMode.HALF_UP).stripTrailingZeros.adaptResult
	}

	def remainder(BigDecimal dividend, BigDecimal divisor) {
		dividend.remainder(divisor)
	}

	def operate(WollokObject other, (Number)=>Number block) {
		val n = other.nativeNumber
		if (n === null) {
			throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_OPERATION_PARAMETER, other))
		}
		val result = block.apply(n.wrapped)
		newInstance(result)
	}

}