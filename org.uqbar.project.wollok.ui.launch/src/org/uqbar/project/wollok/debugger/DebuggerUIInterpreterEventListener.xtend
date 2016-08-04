package org.uqbar.project.wollok.debugger

import org.uqbar.project.wollok.debugger.server.out.XTextInterpreterEventPublisher
import org.eclipse.debug.core.DebugEvent

/**
 * Implements the debugger listener remote interface so
 * that the interpreter/debugger can call us on events.
 * 
 * It just forward events to the WollokDebugTarget object
 * 
 * @author jfernandes
 */
class DebuggerUIInterpreterEventListener implements XTextInterpreterEventPublisher{
	WollokDebugTarget target
	
	new(WollokDebugTarget target) {
		this.target = target
	}
	
	override started() { target.started }
	override terminated() { target.terminated() }
	
	override suspendStep() { target.suspended(DebugEvent.STEP_END) }
	
	override resumeStep() {
		target.WThread.stepping = true
		target.resumed(DebugEvent.STEP_OVER)
	}
	
	override breakpointHit(String fileName, int lineNumber) { target.breakpointHit(fileName, lineNumber) }
	
}