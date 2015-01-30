package org.uqbar.project.wollok.ui.debugger.server.rmi

import java.net.URI
import java.util.List

/**
 * Service interface to connecto to the remote interpreter
 * for debugging.
 * This interface is exposed through lipeRMI
 * 
 * @author jfernandes
 */
interface DebugCommandHandler {
	def void pause()
	def void resume()
	def void stepOver()
	def void stepInto()
	def void stepReturn()
	def void exit()
	
	def void setBreakpoint(URI fileURI, int lineNumber)
	def void clearBreakpoint(URI fileURI, int lineNumber)
	
	def List<XDebugStackFrame> getStackFrames()
	
	
}