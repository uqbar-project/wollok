package org.uqbar.project.wollok.debugger.server.out

import org.uqbar.project.wollok.debugger.server.AbstractCommunicationHandlerRunnable
import org.uqbar.project.wollok.launch.io.CommunicationChannel

import static org.uqbar.project.wollok.debugger.WollokDebugCommands.*

/**
 * Gateway that handles communication with the client debugger.
 * It implements the interface XTextInterpreterEventPublisher that the interpreter
 * uses to publish events.
 * 
 * But it also implements the thread logic to control communication with the remote process
 * through CommuncationChannels.
 * 
 * @author jfernandes
 */
class EventSender extends AbstractCommunicationHandlerRunnable implements XTextInterpreterEventPublisher {
	
	new(CommunicationChannel channel) {
		super(channel)
	}
	
	override incoming(String line) { /* does nothing. It's just for sending */ }
	
	// publisher methods
		
	override started() { sendEvent(EVENT_STARTED) }
	override terminated() { sendEvent(EVENT_TERMINATED) }
	override resumeStep() { sendEvent(EVENT_RESUMED_STEP) }
	override suspendStep() { sendEvent(EVENT_SUSPENDED_STEP) }
	
	// bps
	
	override breakpointHit(String fileName, int lineNumber) {
		// BEWARE ! without the "this" it fails ! Seems like a bug in xtend !
		this.sendEvent(EVENT_SUSPENDED_BREAKPOINT, fileName, lineNumber)
	}
	
}