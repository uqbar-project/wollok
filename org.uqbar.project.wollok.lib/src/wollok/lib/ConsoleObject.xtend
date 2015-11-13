package wollok.lib

import java.io.BufferedReader
import java.io.InputStreamReader
import org.uqbar.project.wollok.interpreter.WollokInterpreter

/**
 * Native implementation of the wollok console object.
 * Has methods to print and read
 * 
 * @author tesonep
 * @author jfernnades 
 */
class ConsoleObject {
	val reader = new BufferedReader(new InputStreamReader(System.in))

	def println(Object obj) {
		WollokInterpreter.getInstance().getConsole().logMessage("" + obj);
	}

	def readLine() {
		reader.readLine
	}

	def readInt() {
		val line = reader.readLine
		Integer.parseInt(line)
	}
}