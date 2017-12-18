package org.uqbar.project.wollok.interpreter.nativeobj

import java.math.BigDecimal
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

interface PrintNumberStrategy {
	def String printString(BigDecimal value)
}

class DecimalPrintingStrategy implements PrintNumberStrategy {
	
	override printString(BigDecimal value) {
		if (value.isInteger) {
			return value.intValue.toString
		}
		value.stripTrailingZeros.toString	
	}
	
}

class PlainPrintingStrategy implements PrintNumberStrategy {
	
	override printString(BigDecimal value) {
		value.toPlainString
	}
	
}