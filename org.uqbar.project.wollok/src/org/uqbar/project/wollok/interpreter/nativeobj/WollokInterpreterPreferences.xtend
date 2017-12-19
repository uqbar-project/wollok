package org.uqbar.project.wollok.interpreter.nativeobj

import org.eclipse.core.runtime.preferences.ConfigurationScope
import org.osgi.service.prefs.Preferences

class WollokInterpreterPreferences {

	public static val DECIMAL_POSITIONS = "Wollok.decimalPositions"
	public static val DECIMAL_POSITIONS_DEFAULT = 5

	public static val NUMBER_COERCING_STRATEGY = "Wollok.coercingStrategy"
	public static val NUMBER_COERCING_STRATEGY_DEFAULT = new TruncateDecimalsCoercionStrategy().description

	public static val NUMBER_PRINTING_STRATEGY = "Wollok.printingStrategy"
	public static val NUMBER_PRINTING_STRATEGY_DEFAULT = new DecimalPrintingStrategy().description

	Preferences prefs = ConfigurationScope.INSTANCE.getNode("org.uqbar.project.wollok.ui")

	private static WollokInterpreterPreferences instance
	 
	static def getInstance() {
		if (instance === null) {
			instance = new WollokInterpreterPreferences
		}
		instance
	}
	
	private new() {}

	def decimalPositions() {
		val result = prefs.getInt(DECIMAL_POSITIONS, DECIMAL_POSITIONS_DEFAULT)
//		if (result == DECIMAL_POSITIONS_DEFAULT) {
//			println("Actualizo decimal positions")
//			prefs.putInt(DECIMAL_POSITIONS, 3)
//			prefs.flush
//		}
		result
	}

	def numberCoercionStrategy() {
		val numberCoercingStrategy = prefs.get(NUMBER_COERCING_STRATEGY, NUMBER_COERCING_STRATEGY_DEFAULT)
		val index = coercingStrategies.map [ description ].indexOf(numberCoercingStrategy)
		coercingStrategies.get(index)
	}
	
	def numberPrintingStrategy() {
		val numberPrintingStrategy = prefs.get(NUMBER_PRINTING_STRATEGY, NUMBER_PRINTING_STRATEGY_DEFAULT)
		val index = printingStrategies.map [ description ].indexOf(numberPrintingStrategy)
		printingStrategies.get(index)
	}
	
	def coercingStrategies() {
		#[new TruncateDecimalsCoercionStrategy, new DecimalsNotAllowedCoercionStrategy, new RoundingDecimalsCoercionStrategy]
	}
	
	def printingStrategies() {
		#[new DecimalPrintingStrategy, new PlainPrintingStrategy]
	}
}
