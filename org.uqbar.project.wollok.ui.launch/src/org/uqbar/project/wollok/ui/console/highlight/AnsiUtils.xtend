package org.uqbar.project.wollok.ui.console.highlight

import static extension org.uqbar.project.wollok.ui.console.highlight.WTextExtensions.*

/**
 * Utiliy methods for ANSI Codes.
 * 
 * @author jfernandes
 */
class AnsiUtils {
	
	def static escapeAnsi(String text) {
		var escaped = text
		val matcher = WollokAnsiColorLineStyleListener.pattern.matcher(text)
		while (matcher.find) {
            escaped = escaped.replace(matcher, ' ')
		}
		escaped

	}

	def static deleteAnsiCharacters(String text) {
		var escaped = text
		val matcher = WollokAnsiColorLineStyleListener.pattern.matcher(text)
		while (matcher.find) {
            escaped = matcher.replaceAll('')
		}
		escaped
	}
	
}