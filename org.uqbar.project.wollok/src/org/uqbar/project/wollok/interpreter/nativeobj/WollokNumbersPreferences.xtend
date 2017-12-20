package org.uqbar.project.wollok.interpreter.nativeobj

import java.io.File
import java.io.FileWriter
import java.io.IOException
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Map
import static org.uqbar.project.wollok.interpreter.nativeobj.WollokNumbersConfigurationProvider.*
import java.nio.file.NoSuchFileException

class WollokNumbersPreferences {
	
	public static val DECIMAL_POSITIONS = "decimalPositions"
	public static val DECIMAL_POSITIONS_DEFAULT = 5

	public static val NUMBER_COERCING_STRATEGY = "coercingStrategy"
	public static val NUMBER_COERCING_STRATEGY_DEFAULT = new TruncateDecimalsCoercionStrategy().description

	public static val NUMBER_PRINTING_STRATEGY = "printingStrategy"
	public static val NUMBER_PRINTING_STRATEGY_DEFAULT = new DecimalPrintingStrategy().description

	private static WollokNumbersPreferences instance
	 
	static def getInstance() {
		if (instance === null) {
			instance = new WollokNumbersPreferences
		}
		instance
	}

	Map<String, String> prefs = newHashMap
		
	private new() {
		println(WollokNumbersConfigurationProvider.getPreferences())
		prefs.putAll(WollokNumbersConfigurationProvider.getPreferences())			
	}
	
	def decimalPositions() {
		new Integer(prefs.getOrDefault(DECIMAL_POSITIONS, "" + DECIMAL_POSITIONS_DEFAULT))	
	}
	
	def numberCoercionStrategy() {
		val numberCoercingStrategy = prefs.getOrDefault(NUMBER_COERCING_STRATEGY, NUMBER_COERCING_STRATEGY_DEFAULT)
		val index = coercingStrategies.map [ description ].indexOf(numberCoercingStrategy)
		coercingStrategies.get(index)
	}
	
	def numberPrintingStrategy() {
		val numberPrintingStrategy = prefs.getOrDefault(NUMBER_PRINTING_STRATEGY, NUMBER_PRINTING_STRATEGY_DEFAULT)
		val index = printingStrategies.map [ description ].indexOf(numberPrintingStrategy)
		printingStrategies.get(index)
	}
	
	def static coercingStrategies() {
		#[new TruncateDecimalsCoercionStrategy, new DecimalsNotAllowedCoercionStrategy, new RoundingDecimalsCoercionStrategy]
	}
	
	def static printingStrategies() {
		#[new DecimalPrintingStrategy, new PlainPrintingStrategy]
	}
	
	def updateKey(String key, String newValue) {
		prefs.put(key, newValue)
		writePreferences(prefs)
	}
	
}

class WollokNumbersConfigurationProvider {

	val static FILE_NAME = "/home/fernando/Desktop/IDEs/numberConfiguration.wollok"
	val static SEPARATOR = " = "
	
	static def Map<String, String> getPreferences() {
		try {
			val path = Paths.get(FILE_NAME)
			val allLines = Files.readAllLines(path, StandardCharsets.UTF_8)
			val result = newHashMap
			allLines.forEach [ line |
				val lineSplit = line.split(SEPARATOR)
				val key = lineSplit.get(0)
				val value = lineSplit.get(1)
				if (key !== null && value !== null && !key.equals("") && !value.equals("")) {
					result.put(key, value)
				}
			]
			return result
		} catch (NoSuchFileException e) {
			newHashMap
		}
	}

	static def writePreferences(Map<String, String> values) {
		try {
			val File file = new File(FILE_NAME)
			new FileWriter(file) => [
				values.keySet.forEach [ key |
					write(key + SEPARATOR + values.get(key))
				]
				flush()
				close()
			]
		} catch (IOException e) {
			e.printStackTrace()
		}
	}

}