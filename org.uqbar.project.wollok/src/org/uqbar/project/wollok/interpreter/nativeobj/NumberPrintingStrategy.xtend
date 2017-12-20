package org.uqbar.project.wollok.interpreter.nativeobj

import java.math.BigDecimal
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

interface NumberPrintingStrategy {
	def String printString(BigDecimal value)
	def String description()
}

class DecimalPrintingStrategy implements NumberPrintingStrategy {
	
	override printString(BigDecimal value) {
		if (value.isInteger) {
			return value.intValue.toString
		}
		value.stripTrailingZeros.toString	
	}
	
	override description() {
		"Decimal printing strategy"
	}
	
}

class PlainPrintingStrategy implements NumberPrintingStrategy {
	
	override printString(BigDecimal value) {
		value.toPlainString
	}
	
	override description() {
		"Plain printing strategy (including trailing zeros)"
	}
	
}