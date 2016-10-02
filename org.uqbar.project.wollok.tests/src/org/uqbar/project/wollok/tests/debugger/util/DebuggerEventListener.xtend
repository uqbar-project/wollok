package org.uqbar.project.wollok.tests.debugger.util

import org.uqbar.project.wollok.debugger.server.rmi.DebugCommandHandler

/**
 * Gets notified about an event that occured to the debugging
 * session.
 * Useful to make assertions or control the flow (resume, pause, etc)
 * 
 * @author jfernandes
 */
interface DebuggerEventListener {
	
	def void started(DebugCommandHandler vm)
	def void terminated(DebugCommandHandler vm)
	
	def void suspended(DebugCommandHandler vm)
	def void resumed(DebugCommandHandler vm)
	
	def void breakpointHit(String fileName, int lineNumber, DebugCommandHandler vm)
	
}