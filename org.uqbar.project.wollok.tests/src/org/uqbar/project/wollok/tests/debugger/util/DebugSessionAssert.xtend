package org.uqbar.project.wollok.tests.debugger.util

import org.uqbar.project.wollok.debugger.server.rmi.DebugCommandHandler

/**
 * Performs an assertion of the debugger session
 * 
 * @author jfernandes
 */
interface DebugSessionAssert {
	
	def void doAssert(DebugCommandHandler vm)
	
}