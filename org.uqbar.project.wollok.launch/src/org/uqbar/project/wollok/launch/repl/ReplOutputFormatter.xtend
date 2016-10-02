package org.uqbar.project.wollok.launch.repl

import static org.fusesource.jansi.Ansi.*
import static org.fusesource.jansi.Ansi.Color.*

/**
 * An strategy to allow ANSI colors output
 * or regular output without special characters
 * 
 * @author jfernandes
 */
interface ReplOutputFormatter {
	def String errorStyle(CharSequence msg)
	def String importantMessageStyle(CharSequence msg)
	def String messageStyle(CharSequence msg)
	def String returnStyle(CharSequence msg)
}

class RegularReplOutputFormatter implements ReplOutputFormatter {
	override def errorStyle(CharSequence msg) { msg.toString }
	override def importantMessageStyle(CharSequence msg) { msg.toString }
	override def messageStyle(CharSequence msg) { msg.toString }
	override def returnStyle(CharSequence msg) { msg.toString }
}


class AnsiColoredReplOutputFormatter implements ReplOutputFormatter {
	static val COLOR_RETURN_VALUE = BLUE
	static val COLOR_ERROR = RED
	static val COLOR_REPL_MESSAGE = CYAN
	
	override def errorStyle(CharSequence msg) { ansi.fg(COLOR_ERROR).a(msg).reset.toString() }
	override def importantMessageStyle(CharSequence msg) { ansi.fg(COLOR_REPL_MESSAGE).bold.a(msg).reset.toString() }
	override def messageStyle(CharSequence msg) { ansi.fg(COLOR_REPL_MESSAGE).a(msg).reset.toString() }
	override def returnStyle(CharSequence msg) { ansi().fg(COLOR_RETURN_VALUE).a(msg).reset.toString() }
}