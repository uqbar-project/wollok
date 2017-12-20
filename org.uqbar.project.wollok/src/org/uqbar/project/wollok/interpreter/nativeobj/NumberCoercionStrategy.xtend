package org.uqbar.project.wollok.interpreter.nativeobj

import java.math.BigDecimal
import java.math.MathContext
import java.math.RoundingMode
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

interface NumberCoercionStrategy {
	def int coerceToInteger(BigDecimal value)
	def BigDecimal adaptValue(BigDecimal value)
	def String description()
}

class TruncateDecimalsCoercionStrategy implements NumberCoercionStrategy {
	override coerceToInteger(BigDecimal value) {
		val result = value.intValue
		try {
			value.intValueExact
		} catch (ArithmeticException e) {
			println(NLS.bind(Messages.WollokConversion_WARNING_NUMBER_VALUE_INTEGER, value, result))
		}
		result
	}
	override adaptValue(BigDecimal value) { 
		val result = value.setScale(WollokNumbersPreferences.instance.decimalPositions, RoundingMode.HALF_UP)
		if (value.scale > WollokNumbersPreferences.instance.decimalPositions) {
			println(NLS.bind(Messages.WollokConversion_WARNING_NUMBER_VALUE_INTEGER, value, result))
		}
		result
	}
	override description() {
		"Truncating decimals coercion strategy"
	}
	
}

class DecimalsNotAllowedCoercionStrategy implements NumberCoercionStrategy {
	
	override coerceToInteger(BigDecimal value) {
		try {
			value.intValueExact			
		} catch (ArithmeticException e) {
			throw new WollokProgramExceptionWrapper(newWollokException(NLS.bind(Messages.WollokConversion_INTEGER_VALUE_REQUIRED, value)))
		}
	}
	
	override adaptValue(BigDecimal value) {
		if (value.scale > WollokNumbersPreferences.instance.decimalPositions) {
			throw new WollokProgramExceptionWrapper(newWollokException(NLS.bind(Messages.WollokConversion_DECIMAL_SCALE_REQUIRED, value, WollokNumbersPreferences.instance.decimalPositions)))
		}
		value.setScale(WollokNumbersPreferences.instance.decimalPositions, RoundingMode.UNNECESSARY)
	}

	override description() {
		"Exceeding decimals not allowed (throwing errors)"
	}

}

class RoundingDecimalsCoercionStrategy implements NumberCoercionStrategy {
	
	override coerceToInteger(BigDecimal value) {
		value.round(new MathContext(1, RoundingMode.HALF_UP)).intValue
	}
	override adaptValue(BigDecimal value) { value.setScale(WollokNumbersPreferences.instance.decimalPositions, RoundingMode.DOWN) }
	
	override description() {
		"Rounding decimals coercion strategy"
	}
	
}