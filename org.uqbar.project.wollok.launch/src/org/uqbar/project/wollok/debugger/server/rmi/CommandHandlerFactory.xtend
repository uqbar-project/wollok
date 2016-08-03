package org.uqbar.project.wollok.debugger.server.rmi

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
	
	def static Server createCommandHandler(XDebugger debugger, int port, ()=>void onReady) {
		val server = new Server
		new CallHandler => [
			registerGlobal(DebugCommandHandler, new DebugCommandHandlerImpl(debugger, server, onReady))
//			server.bind(port, it, new DebuggingProtocolFilter) // use this to debug RMI
			server.bind(port, it)
		]
		server
	}
	
	def static remoteObjectName() { DebugCommandHandler.simpleName }

}