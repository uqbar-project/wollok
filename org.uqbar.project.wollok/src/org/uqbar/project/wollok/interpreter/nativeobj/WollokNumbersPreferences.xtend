package org.uqbar.project.wollok.interpreter.nativeobj

import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors

import static org.uqbar.project.wollok.Messages.*

class WollokNumbersPreferences {

	@Accessors int decimalPositions
	@Accessors NumberCoercingStrategy numberCoercingStrategy
	@Accessors NumberPrintingStrategy numberPrintingStrategy

	@Accessors
	val coercingStrategies = #[new TruncateDecimalsCoercingStrategy, new DecimalsNotAllowedCoercingStrategy, new RoundingDecimalsCoercingStrategy] 
	@Accessors
	val printingStrategies = #[new DecimalPrintingStrategy, new PlainPrintingStrategy]
		
	public static val DECIMAL_POSITIONS_DEFAULT = 5
	public static val NUMBER_COERCING_STRATEGY_DEFAULT = new RoundingDecimalsCoercingStrategy()
	public static val NUMBER_PRINTING_STRATEGY_DEFAULT = new DecimalPrintingStrategy()

	static WollokNumbersPreferences instance	
	 
	static def getInstance() {
		if (instance === null) {
			instance = new WollokNumbersPreferences
		}
		instance
	}

	private new() {
		decimalPositions = DECIMAL_POSITIONS_DEFAULT
		numberCoercingStrategy = NUMBER_COERCING_STRATEGY_DEFAULT
		numberPrintingStrategy = NUMBER_PRINTING_STRATEGY_DEFAULT
	}
		
	def setNumberCoercingStrategyByName(String coercingName) {
		val value = coercingStrategies.findFirst[ name == coercingName ]
		if(value === null){
			throw new RuntimeException(NLS.bind(WollokNumberPreferences_COERCING_STRATEGY_NOTFOUND, coercingName))
		}
		
		numberCoercingStrategy = value
	}
	
	def setNumberPrintingStrategyByName(String printingName) {
		val value = printingStrategies.findFirst[ name == printingName ]
		if(value === null){
			throw new RuntimeException(NLS.bind(WollokNumberPreferences_PRINTING_STRATEGY_NOTFOUND, printingName))
		}
		
		numberPrintingStrategy = value
	}
	
}