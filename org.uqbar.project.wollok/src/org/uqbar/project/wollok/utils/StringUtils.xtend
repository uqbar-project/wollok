package org.uqbar.project.wollok.utils

import java.text.DecimalFormat

/**
 * 
 * @author jfernandes
 */
class StringUtils {

	def static splitCamelCase(String s) {
		s.replaceAll(
			String.format(
				"%s|%s|%s",
				"(?<=[A-Z])(?=[A-Z][a-z])",
				"(?<=[^A-Z])(?=[A-Z])",
				"(?<=[A-Za-z])(?=[^A-Za-z])"
			),
			" "
		)
	}

	def static firstUpper(String s) {
		Character.toUpperCase(s.charAt(0)) + s.substring(1)
	}

	def static String padRight(String s, int n) {
		return String.format("%1$-" + n + "s", s);
	}

	def static String truncate(String value, int max) {
		if (value === null) return ""
		if (value.length < max) return value
		value.substring(0, max) + "..."
	}

	/**
	 * Divides a string into lines
	 */
	static def lines(CharSequence input) { input.toString.split("[" + System.lineSeparator() + "]+") }

	/**
	 * Returns a substring from the begining until the last occurrence of a given character.  
	 */
	static def copyUptoLast(String string, Character character) {
		string.substring(0, string.lastIndexOf(character))
	}
	
	static def safeLength(String value) {
		(value ?: "").length
	}
	
	static def asSeconds(long milliseconds) {
		val float seconds = milliseconds / 1000f
		new DecimalFormat("##########.###").format(seconds)
	}

	static def singularOrPlural(int amount, String text) {
		amount.singularOrPlural(text, text + "s")
	}

	static def singularOrPlural(int amount, String text, String pluralText) {
		"" + amount + " " + if (amount === 1) text else pluralText
	}

	static def boolean notEmpty(String value) {
		value !== null && !value.equals("")
	}
	
	static def getPackage(String name) {
		name.copyUptoLast(".")
	}
		
}
