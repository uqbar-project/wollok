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
}

class TruncateDecimalsCoercionStrategy implements NumberCoercionStrategy {
	override coerceToInteger(BigDecimal value) {
		try {
			value.intValueExact
		} catch (ArithmeticException e) {
			println(NLS.bind(Messages.WollokConversion_WARNING_NUMBER_VALUE_INTEGER, value, value.intValue))
		}
		value.intValue
	}
	override adaptValue(BigDecimal value) { 
		value.setScale(WollokConstants.decimalPrecision, RoundingMode.HALF_UP)
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
		if (value.scale > WollokConstants.decimalPrecision) {
			throw new WollokProgramExceptionWrapper(newWollokException(NLS.bind(Messages.WollokConversion_DECIMAL_SCALE_REQUIRED, value, value.scale)))
		}
		value.setScale(WollokConstants.decimalPrecision, RoundingMode.UNNECESSARY)
	}

}

class RoundingDecimalsCoercionStrategy implements NumberCoercionStrategy {
	
	override coerceToInteger(BigDecimal value) {
		value.round(new MathContext(1, RoundingMode.HALF_UP)).intValue
	}
	override adaptValue(BigDecimal value) { value.setScale(WollokConstants.decimalPrecision, RoundingMode.DOWN) }
	
}