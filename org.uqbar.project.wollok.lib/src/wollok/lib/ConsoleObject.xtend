package wollok.lib

import java.io.BufferedReader
import java.io.InputStreamReader
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * Native implementation of the wollok console object.
 * Has methods to print and read
 * 
 * @author tesonep
 * @author jfernnades 
 */
class ConsoleObject {
	// TODO Reader is hard coded.
	val reader = new BufferedReader(new InputStreamReader(System.in))
	val WollokInterpreter interpreter

	new(WollokObject unused, WollokInterpreter interpreter) {
		this.interpreter = interpreter
	}

	def println(Object obj) {
		// TODO We does the interpreter have the console and not me?
		interpreter.getConsole().logMessage("" + obj);
	}

	def readLine() {
		reader.readLine
	}

	def readInt() {
		val line = reader.readLine
		Integer.parseInt(line)
	}
}
