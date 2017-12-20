package org.uqbar.project.wollok.interpreter.nativeobj

import java.math.BigDecimal
import java.math.MathContext
import java.math.RoundingMode
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

interface NumberCoercingStrategy {
	def int coerceToInteger(BigDecimal value)
	def BigDecimal adaptValue(BigDecimal value)
	def String description()
}

class TruncateDecimalsCoercingStrategy implements NumberCoercingStrategy {
	override coerceToInteger(BigDecimal value) {
		val result = value.setScale(0, RoundingMode.DOWN).intValue
		try {
			value.intValueExact
		} catch (ArithmeticException e) {
			println(NLS.bind(Messages.WollokConversion_WARNING_NUMBER_VALUE_INTEGER, value, result))
		}
		result
	}
	
	override adaptValue(BigDecimal value) { 
		val result = value.setScale(WollokNumbersPreferences.instance.decimalPositions, RoundingMode.DOWN)
		if (value.scale > WollokNumbersPreferences.instance.decimalPositions) {
			println(NLS.bind(Messages.WollokConversion_WARNING_NUMBER_VALUE_INTEGER, value, result))
		}
		result
	}
	override description() {
		"Truncating decimals coercion strategy"
	}
	
}

class DecimalsNotAllowedCoercingStrategy implements NumberCoercingStrategy {
	
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

class RoundingDecimalsCoercingStrategy implements NumberCoercingStrategy {
	
	override coerceToInteger(BigDecimal value) {
		value.intValue
	}
	override adaptValue(BigDecimal value) { value.setScale(WollokNumbersPreferences.instance.decimalPositions, RoundingMode.HALF_UP) }
	
	override description() {
		"Rounding decimals coercion strategy"
	}
	
}