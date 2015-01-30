package org.uqbar.project.wollok.ui.debugger.server.rmi

import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Server
import org.uqbar.project.wollok.interpreter.api.XDebugger

/**
 * Interpreter side command listeners and handler.
 * Impl based on RMI protocol
 * 
 * @author jfernandes
 */
class CommandHandlerFactory {
	
	def static createCommandHandler(XDebugger debugger, int port) {
		val callHandler = new CallHandler
		val server = new Server
		
		callHandler.registerGlobal(DebugCommandHandler, new DebugCommandHandlerImpl(debugger, server))
		server.bind(port, callHandler)
	}
	
	def static remoteObjectName() { DebugCommandHandler.simpleName }

}