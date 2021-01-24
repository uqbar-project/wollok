package org.uqbar.project.wollok.interpreter.core

import java.lang.reflect.Method
import java.io.StringWriter
import java.io.PrintWriter

/**
 * Wrap a exception ocurred into native method
 * @author lgassman
 * 
 */
class WollokNativeExceptionWrapper extends WollokProgramExceptionWrapper {
	
	val Throwable nativeException
	
	new(WollokObject wollokException, Throwable cause) {
		super(wollokException)
		nativeException = cause
	}
	
	def getNaviteException() {
		nativeException
	}
	
	def nativeAsString() {
		val writer = new StringWriter();
		val printWriter = new PrintWriter(writer);
		naviteException.printStackTrace(printWriter)
		return "native Exception: \n" + writer.toString			
	}
	
}