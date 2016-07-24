package org.uqbar.project.wollok.debugger.server.rmi

import com.google.common.collect.Lists
import java.net.URI
import java.util.List
import net.sf.lipermi.net.Server
import org.uqbar.project.wollok.interpreter.api.XDebugger

/**
 * DebugCommandHandler implementation.
 * It delegates messages to the debugger.
 * And handles the RMI Server object.
 * 
 * Also "adapts" the stack elements
 * 
 * @author jfernandes
 */
class DebugCommandHandlerImpl implements DebugCommandHandler {
	Server server
	XDebugger debugger
	()=>void onReady
	
	new(XDebugger debugger, Server server, ()=>void onReady) {
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
	
	override List<XDebugStackFrame> getStackFrames() {
//		println("[VM] Client asked for stack frames ")
		val n = Lists.newArrayList(debugger.stack.map[
//			println("[VM] Mapping stack element " + it)
			new XDebugStackFrame(it)
		])
//		println("[VM] Returning stack frames to client")
		n
	}
	
}