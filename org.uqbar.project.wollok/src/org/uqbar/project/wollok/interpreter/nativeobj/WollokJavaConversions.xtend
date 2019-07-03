package org.uqbar.project.wollok.interpreter.nativeobj

import java.math.BigDecimal
import java.math.BigInteger
import java.time.LocalDate
import java.util.Collection
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.osgi.util.NLS
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * Holds common extensions for Wollok to Java and Java to Wollok conversions.
 * 
 * @author jfernandes
 */
class WollokJavaConversions {

	def static asNumber(WollokObject it) {
		((it as WollokObject).getNativeObject(NUMBER) as JavaWrapper<BigDecimal>).wrapped
	}

	def static isWBoolean(Object it) { it instanceof WollokObject && (it as WollokObject).hasNativeType(BOOLEAN) }

	def static isTrue(Object it) {
		it instanceof WollokObject && ((it as WollokObject).getNativeObject(BOOLEAN) as JavaWrapper<Boolean>).wrapped
	}

	/**
	 * Only used to show a representative error message when converting Java and Wollok types
	 */
	def static Map<?,?> conversionTypes() {
		#{Function1 -> CLOSURE, BigDecimal -> NUMBER, String -> STRING,
			List -> LIST, Map -> DICTIONARY, Set -> SET, Boolean -> BOOLEAN,
			LocalDate -> DATE
		}
	}
	
	def static Object wollokToJava(Object o, Class<?> t) {
		if (o === null) return null
		if (t.isInstance(o)) return o
		if (t == Object) return o

		if (o.isNativeType(CLOSURE) && t == Function1)
			return [Object a|((o as WollokObject).getNativeObject(CLOSURE) as Function1).apply(a)]
		if (o.isNativeType(NUMBER) && (t == BigDecimal || t == Double.TYPE))
			return ((o as WollokObject).getNativeObject(NUMBER) as JavaWrapper<BigDecimal>).wrapped.adaptValue
		if (o.isNativeType(STRING) && t == String)
			return ((o as WollokObject).getNativeObject(STRING) as JavaWrapper<String>).wrapped
		if (o.isNativeType(LIST) && (t == Collection || t == List))
			return ((o as WollokObject).getNativeObject(LIST) as JavaWrapper<List<?>>).wrapped
		if (o.isNativeType(DICTIONARY) && (t == Collection || t == Map))
			return ((o as WollokObject).getNativeObject(DICTIONARY) as JavaWrapper<Map<?,?>>).wrapped
		if (o.isNativeType(SET) && (t == Collection || t == Set))
			return ((o as WollokObject).getNativeObject(SET) as JavaWrapper<Set<?>>).wrapped
		if (o.isNativeType(BOOLEAN) && (t == Boolean || t == Boolean.TYPE))
			return ((o as WollokObject).getNativeObject(BOOLEAN) as JavaWrapper<Boolean>).wrapped
		if (o.isNativeType(DATE)) {
			return ((o as WollokObject).getNativeObject(DATE) as JavaWrapper<LocalDate>).wrapped
		}

		if (t == Collection || t == List)
			return #[o]

		// remove this ?
		if (t.
			primitive)
			return o

		throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_CONVERSION, (o as WollokObject).call("printString"), conversionTypes.get(t) ?: t.simpleName))
	}

	def static dispatch isNativeType(Object o, String type) { false }

	def static dispatch isNativeType(Void o, String type) { false }

	def static dispatch isNativeType(WollokObject o, String type) { o.hasNativeType(type) }

	def static WollokObject javaToWollok(Object o) {
		if (o === null) return null
		convertJavaToWollok(o)
	}

	def static dispatch WollokObject convertJavaToWollok(BigInteger o) { evaluator.getOrCreateNumber(o.toString) }

	def static dispatch WollokObject convertJavaToWollok(Long o) { evaluator.getOrCreateNumber(o.toString) }

	def static dispatch WollokObject convertJavaToWollok(Integer o) { evaluator.getOrCreateNumber(o.toString) }

	def static dispatch WollokObject convertJavaToWollok(Double o) { evaluator.getOrCreateNumber(o.toString) }

	def static dispatch WollokObject convertJavaToWollok(BigDecimal o) { evaluator.getOrCreateNumber(o.toString) }

	// cache strings ?
	def static dispatch WollokObject convertJavaToWollok(String o) { evaluator.newInstanceWithWrapped(STRING, o) }

	def static dispatch WollokObject convertJavaToWollok(Boolean o) { evaluator.booleanValue(o) }

	def static dispatch WollokObject convertJavaToWollok(List<?> o) { evaluator.newInstanceWithWrapped(LIST, o) }

	def static dispatch WollokObject convertJavaToWollok(Set<?> o) { evaluator.newInstanceWithWrapped(SET, o) }

	def static dispatch WollokObject convertJavaToWollok(LocalDate o) { evaluator.newInstanceWithWrapped(DATE, o) }

	def static dispatch WollokObject convertJavaToWollok(WollokObject it) { it }

	def static dispatch WollokObject convertJavaToWollok(Object o) {
		throw WollokJavaConversions.throwInvalidOperation(NLS.bind(Messages.WollokConversion_UNSUPPORTED_CONVERSION_JAVA_WOLLOK, (o as WollokObject).call("printString"), o.class.name))
	}

	def static WollokProgramExceptionWrapper newWollokExceptionAsJava(String message) {
		new WollokProgramExceptionWrapper(newWollokException(message))
	}

	def static newWollokException(String message) {
		evaluator.newInstance(EXCEPTION, message.javaToWollok)
	}

	def static newWollokException(String message, WollokObject cause) {
		evaluator.newInstance(EXCEPTION, message.javaToWollok, cause)
	}

	def static newWollokAssertionException(String message) {
		evaluator.newInstance(ASSERTION_EXCEPTION_FQN, message.javaToWollok)
	}

	def static getEvaluator() { (WollokInterpreter.getInstance.evaluator as WollokInterpreterEvaluator) }

	/**
	 * Numeric conversions
	 */
	 
	/**
	 * Just for internal use only
	 * You know you use an integer value (like positions of a Game object) and you don't
	 * want to read IDE preferences
	 */
	def static int asInteger(WollokObject o) {
		o.asNumber.intValue
	}
	
	def static int coerceToPositiveInteger(BigDecimal value) {
		if (value.intValue < 0) {
			throw WollokJavaConversions.throwInvalidOperation(NLS.bind(Messages.WollokConversion_POSITIVE_INTEGER_VALUE_REQUIRED, value))
		}
		value.coerceToInteger
	}
	
	def static dispatch int coerceToInteger(Integer value) { value }
	
	def static dispatch int coerceToInteger(WollokObject o) {
		var int result
		try {
			result = o.asNumber.coerceToInteger
		} catch (NumberFormatException e) {
			throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_CONVERSION, o.call("printString"), "Number"))
		} catch (ClassCastException c) {
			throw throwInvalidOperation(NLS.bind(Messages.WollokConversion_INVALID_CONVERSION, o.call("printString"), "Number"))
		}
		result
	} 
	
	def static dispatch int coerceToInteger(BigDecimal value) {
		coercingStrategy.coerceToInteger(value)
	}
	
	def static Throwable throwInvalidOperation(String message) {
		new WollokProgramExceptionWrapper(newWollokException(message))
	}
	
	def static String printValueAsString(BigDecimal value) {
		printingStrategy.printString(value)
	}
	
	def static BigDecimal adaptValue(BigDecimal value) {
		coercingStrategy.adaptValue(value)
	}

	def static BigDecimal adaptResult(BigDecimal value) {
		coercingStrategy.adaptResult(value)
	}
	
	def static isInteger(BigDecimal value) {
		value.signum == 0 || value.scale <= 0 || value.stripTrailingZeros.scale <= 0
	}

	def static NumberCoercingStrategy coercingStrategy() {
		WollokNumbersPreferences.instance.numberCoercingStrategy
	}
	
	def static NumberPrintingStrategy printingStrategy() {
		WollokNumbersPreferences.instance.numberPrintingStrategy
	}
	
}