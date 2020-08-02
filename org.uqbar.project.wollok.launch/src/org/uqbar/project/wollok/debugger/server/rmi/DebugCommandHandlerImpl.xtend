package org.uqbar.project.wollok.debugger.server.rmi

import com.google.common.collect.Lists
import java.net.URI
import net.sf.lipermi.net.Server
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * DebugCommandHandler implementation.
 * It delegates messages to the debugger.
 * And handles the RMI Server object.
 * 
 * Also "adapts" the stack elements
 * 
 * @author jfernandes
 */
// this should probably have a better name
class DebugCommandHandlerImpl implements DebugCommandHandler {
	Server server
	XDebugger<WollokObject> debugger
	()=>void onReady
	
	new(XDebugger<WollokObject> debugger, Server server, ()=>void onReady) {
		this.debugger = debugger
		this.server = server
		this.onReady = onReady
	}
	
	override clientReady() {
		onReady.apply()
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
	
	override getStackFrames() throws WollokDebuggerException {
		try {
			Lists.newArrayList(debugger.stack.map[
				new XDebugStackFrame(it)
			])
		}
		catch (RuntimeException e) {
			throw new WollokDebuggerException("Error while getting current stack trace", e)
		}
	}
	
}