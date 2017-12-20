package org.uqbar.project.wollok.interpreter.nativeobj

import java.io.File
import java.io.FileWriter
import java.io.IOException
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.NoSuchFileException
import java.nio.file.Paths
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokNumbersConfigurationProvider.*

class WollokNumbersPreferences {

	@Accessors int decimalPositions
	@Accessors NumberCoercingStrategy numberCoercingStrategy
	@Accessors NumberPrintingStrategy numberPrintingStrategy
	Map<String, String> prefs = newHashMap
		
	public static val DECIMAL_POSITIONS = "decimalPositions"
	public static val DECIMAL_POSITIONS_DEFAULT = 5

	public static val NUMBER_COERCING_STRATEGY = "coercingStrategy"
	public static val NUMBER_COERCING_STRATEGY_DEFAULT = new RoundingDecimalsCoercingStrategy().description

	public static val NUMBER_PRINTING_STRATEGY = "printingStrategy"
	public static val NUMBER_PRINTING_STRATEGY_DEFAULT = new DecimalPrintingStrategy().description

	private static WollokNumbersPreferences instance
	 
	static def getInstance() {
		if (instance === null) {
			instance = new WollokNumbersPreferences
		}
		instance
	}

	private new() {
		prefs.putAll(WollokNumbersConfigurationProvider.getPreferences())			
		decimalPositions = new Integer(prefs.getOrDefault(DECIMAL_POSITIONS, "" + DECIMAL_POSITIONS_DEFAULT))
		numberCoercingStrategy = calculateNumberCoercingStrategy(prefs)
		numberPrintingStrategy = calculateNumberPrintingStrategy(prefs)
	}

	def initializeForTests() {
		decimalPositions = DECIMAL_POSITIONS_DEFAULT
		numberCoercingStrategy = calculateNumberCoercingStrategy(NUMBER_COERCING_STRATEGY_DEFAULT)
		numberPrintingStrategy = calculateNumberPrintingStrategy(NUMBER_PRINTING_STRATEGY_DEFAULT)
	}
	
	def static coercingStrategies() {
		#[new TruncateDecimalsCoercingStrategy, new DecimalsNotAllowedCoercingStrategy, new RoundingDecimalsCoercingStrategy]
	}
	
	def static printingStrategies() {
		#[new DecimalPrintingStrategy, new PlainPrintingStrategy]
	}
	
	def updateKey(String key, String newValue) {
		prefs.put(key, newValue)
		writePreferences(prefs)
	}

	/** *******************************************************************
	 *                         INTERNAL METHODS
	 * ********************************************************************
	 */	
	
	private def calculateNumberCoercingStrategy(Map<String, String> prefs) {
		val coercingDescription = prefs.getOrDefault(NUMBER_COERCING_STRATEGY, NUMBER_COERCING_STRATEGY_DEFAULT)
		calculateNumberCoercingStrategy(coercingDescription)
	}

	private def calculateNumberCoercingStrategy(String coercingDescription) {
		val index = coercingStrategies.map [ description ].indexOf(coercingDescription)
		coercingStrategies.get(index)
	}
	
	private def calculateNumberPrintingStrategy(Map<String, String> prefs) {
		val printingDescription = prefs.getOrDefault(NUMBER_PRINTING_STRATEGY, NUMBER_PRINTING_STRATEGY_DEFAULT)
		calculateNumberPrintingStrategy(printingDescription)
	}
	
	private def calculateNumberPrintingStrategy(String printingDescription) {
		val index = printingStrategies.map [ description ].indexOf(printingDescription)
		printingStrategies.get(index)
	}

}

class WollokNumbersConfigurationProvider {

	val static FILE_NAME = System.getProperty("user.home") + File.separator + "numberConfiguration.wollok"
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
			e.printStackTrace
			newHashMap
		}
	}

	static def writePreferences(Map<String, String> values) {
		try {
			val File file = new File(FILE_NAME)
			new FileWriter(file) => [
				values.keySet.forEach [ key |
					write(key + SEPARATOR + values.get(key) + "\n")
				]
				flush()
				close()
			]
		} catch (IOException e) {
			e.printStackTrace()
		}
	}

}