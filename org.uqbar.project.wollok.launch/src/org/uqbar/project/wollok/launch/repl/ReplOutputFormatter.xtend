package org.uqbar.project.wollok.launch.repl

import org.fusesource.jansi.Ansi

import static org.fusesource.jansi.Ansi.*
import static org.fusesource.jansi.Ansi.Color.*

/**
 * An strategy to allow ANSI colors output
 * or regular output without special characters
 * 
 * https://github.com/fusesource/jansi
 * 
 * @author jfernandes
 */
interface ReplOutputFormatter {
	def String errorStyle(CharSequence msg)
	def String importantMessageStyle(CharSequence msg)
	def String messageStyle(CharSequence msg)
	def String returnStyle(CharSequence msg)
	def String linkStyle(CharSequence msg)
	def String normalStyle(CharSequence msg)
}

class RegularReplOutputFormatter implements ReplOutputFormatter {
	override errorStyle(CharSequence msg) { msg.toString }
	override importantMessageStyle(CharSequence msg) { msg.toString }
	override messageStyle(CharSequence msg) { msg.toString }
	override returnStyle(CharSequence msg) { msg.toString }
	override linkStyle(CharSequence msg) { msg.toString }
	override normalStyle(CharSequence msg) { msg.toString }
}


class AnsiColoredReplOutputFormatter implements ReplOutputFormatter {
	static val COLOR_RETURN_VALUE = BLUE
	static val COLOR_ERROR = RED
	static val COLOR_REPL_MESSAGE = CYAN
	static val COLOR_LINK_FILE = BLUE
	static val COLOR_DEFAULT = DEFAULT
	
	override errorStyle(CharSequence msg) { ansi.fg(COLOR_ERROR).a(msg).reset.toString() }
	override importantMessageStyle(CharSequence msg) { ansi.fg(COLOR_REPL_MESSAGE).bold.a(msg).reset.toString() }
	override messageStyle(CharSequence msg) { ansi.fg(COLOR_REPL_MESSAGE).a(msg).reset.toString() }
	override returnStyle(CharSequence msg) { ansi().fg(COLOR_RETURN_VALUE).a(msg).reset.toString() }
	override linkStyle(CharSequence msg) { 
		// https://mihai-nita.net/2013/06/03/eclipse-plugin-ansi-in-console/
		ansi.fg(COLOR_LINK_FILE).a(Ansi.Attribute.UNDERLINE).boldOff.a(msg).reset.a(Ansi.Attribute.UNDERLINE_OFF).bold.a(Ansi.Attribute.RESET).toString
	}
	override normalStyle(CharSequence msg) { ansi.fg(COLOR_DEFAULT).a(msg).reset.toString() }
}