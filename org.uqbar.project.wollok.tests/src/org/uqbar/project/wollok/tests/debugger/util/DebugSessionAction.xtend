package org.uqbar.project.wollok.tests.debugger.util

import org.uqbar.project.wollok.debugger.server.rmi.DebugCommandHandler

/**
 * Something to be done during a debugging session.
 * Usually you will send a command to the VM like: 
 * 	- resume()
 *  - terminate()
 *  - etc
 * 
 * @author jfernandes
 */
interface DebugSessionAction {

	def void execute(DebugCommandHandler vm)
	
}