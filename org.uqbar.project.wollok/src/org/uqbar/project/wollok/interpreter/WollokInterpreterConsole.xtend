package org.uqbar.project.wollok.interpreter

import java.io.Serializable
import com.google.inject.Singleton

/**
 * A console where the interpreter will write stuff into.
 * 
 * @author jfernandes
 */
interface WollokInterpreterConsole extends Serializable {	
	def void logMessage(String message)
	def void logError(String message)
	def void logError(Throwable exception)
}

/**
 * Impl that writes directly to sys out and sys.err
 * @author jfernandes
 */
@Singleton
class SysoutWollokInterpreterConsole implements WollokInterpreterConsole {
	override logMessage(String message) { println(message)	}
	override logError(Throwable exception) { exception.printStackTrace }
	override logError(String message) { System.err.println(message) }
}
