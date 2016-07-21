package org.uqbar.project.wollok.server

import java.io.PrintWriter
import java.io.StringWriter
import org.uqbar.project.wollok.interpreter.WollokInterpreterConsole
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * This console accumulates messages into a string in order to include them in the server response.
 * 
 * @author npasserini
 */
class WollokServerConsole implements WollokInterpreterConsole {
	@Accessors
	val output = new StringWriter
	val writer = new PrintWriter(output)
	
	override logMessage(String message) { writer.println(message)	}
	override logError(Throwable exception) { exception.printStackTrace(writer) }
	
	/**
	 * TODO Is it right to send errors to the same place as messages?
	 */
	override logError(String message) { writer.println(message) }
	
	def getConsoleOutput() {
		writer.flush
		output.toString
	}
}
