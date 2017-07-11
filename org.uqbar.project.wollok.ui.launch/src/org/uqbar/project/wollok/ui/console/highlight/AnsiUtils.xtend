package org.uqbar.project.wollok.ui.console.highlight

import java.util.regex.Matcher
import java.util.regex.Pattern

/**
 * Utiliy methods for ANSI Codes.
 * 
 * @author jfernandes
 */
class AnsiUtils {

	public static val Pattern pattern = Pattern.compile("\u001b\\[[\\d;]*[A-HJKSTfimnsu]")

	def static escapeAnsi(String text) {
		var escaped = text
		val matcher = pattern.matcher(text)
		while (matcher.find) {
			escaped = escaped.replace(matcher, ' ')
		}
		escaped
	}

	def static deleteAnsiCharacters(String text) {
		var escaped = text
		var matcher = pattern.matcher(text)
		while (matcher.find) {
			escaped = matcher.replaceAll('')
		}
		matcher = Pattern.compile("\\[m").matcher(escaped) 
		while (matcher.find) {
			escaped = matcher.replaceAll('')
		}
		escaped
	}

	def static replace(String str, Matcher it, String replacement) {
		str.substring(0, start) + (replacement * (end - start)) + str.substring(end)
	}

	def static operator_multiply(String s, int n) { (1 .. n).map[' '].join }
}
