package org.uqbar.project.wollok.interpreter.nativeobj

import org.eclipse.core.runtime.Platform
import org.eclipse.core.runtime.preferences.IPreferencesService
import org.eclipse.core.runtime.preferences.InstanceScope
import org.osgi.service.prefs.Preferences

class WollokNumbersPreferences {

	public static val DECIMAL_POSITIONS = "decimalPositions"
	public static val DECIMAL_POSITIONS_DEFAULT = 5

	public static val NUMBER_COERCING_STRATEGY = "coercingStrategy"
	public static val NUMBER_COERCING_STRATEGY_DEFAULT = new TruncateDecimalsCoercionStrategy().description

	public static val NUMBER_PRINTING_STRATEGY = "printingStrategy"
	public static val NUMBER_PRINTING_STRATEGY_DEFAULT = new DecimalPrintingStrategy().description

	Preferences prefs = InstanceScope.INSTANCE.getNode("org.uqbar.project.wollok.WollokDsl")

	private static WollokNumbersPreferences instance
	 
	static def getInstance() {
		if (instance === null) {
			instance = new WollokNumbersPreferences
		}
		instance
	}
	
	private new() {
	}

	def decimalPositions() {
		prefs.getInt(DECIMAL_POSITIONS, DECIMAL_POSITIONS_DEFAULT)
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
	
	def static coercingStrategies() {
		#[new TruncateDecimalsCoercionStrategy, new DecimalsNotAllowedCoercionStrategy, new RoundingDecimalsCoercionStrategy]
	}
	
	def static printingStrategies() {
		#[new DecimalPrintingStrategy, new PlainPrintingStrategy]
	}
}
