package org.uqbar.project.wollok.interpreter

import com.google.inject.Singleton
import java.io.Serializable

import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*

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
	override logError(Throwable exception) { println(exception.convertToString) }
	override logError(String message) { System.err.println(message) }
}
