package org.uqbar.project.wollok.ui.debugger.server.rmi

import java.net.URI
import net.sf.lipermi.net.Server
import org.uqbar.project.wollok.interpreter.api.XDebugger

/**
 * DebugCommandHandler implementation.
 * It delegates messages to the debugger.
 * 
 * @author jfernandes
 */
class DebugCommandHandlerImpl implements DebugCommandHandler {
	Server server
	XDebugger debugger
	
	new(XDebugger debugger, Server server) {
		this.debugger = debugger
		this.server = server
	}
	
	override pause() { debugger.pause }
	override resume() { debugger.resume }
	override stepOver() { debugger.stepOver }
	override stepInto() { debugger.stepInto }
	override stepReturn() { debugger.stepReturn }

	override exit() { 
		debugger.terminate
		server.close
	}
	
	override setBreakpoint(URI fileURI, int lineNumber) {
		debugger.setBreakpoint(fileURI.toString, lineNumber)
	}
	
	override clearBreakpoint(URI fileURI, int lineNumber) {
		debugger.clearBreakpoint(fileURI.toString, lineNumber)
	}
	
	override getStackFrames() {
		newArrayList(debugger.stack.map[new XDebugStackFrame(it)])
	}
	
}