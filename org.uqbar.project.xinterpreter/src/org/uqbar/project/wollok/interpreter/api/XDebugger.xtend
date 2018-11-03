package org.uqbar.project.wollok.interpreter.api

import java.io.Serializable
import java.util.Stack
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

/**
 * Interface used by the interpreter in order to keep the debugger
 * updated on what is doing.
 * 
 * This methods could block the calling thread for example to wait
 * for the user to resume the execution.
 * 
 * The interface allows us have a dummy impl for running in "non-debug" mode.
 * 
 * @author jfernandes
 */
interface XDebugger extends Serializable, XInterpreterListener {
	
	// *****************************************
	// METHODS CALLED FROM THE REMOTE DEBUGGER (won't be called if it's not in debug mode)
	// *****************************************
	
	/**
	 * Terminates the interpreter execution
	 */
	def void terminate()
	
	def void stepOver()
	def void stepInto()
	def void stepReturn()
	def void pause()
	def void resume()
	def Stack<XStackFrame> getStack()
		
	// BPs
	def void setBreakpoint(String fileURI, int line)
	def void clearBreakpoint(String fileURI, int line)
	
}