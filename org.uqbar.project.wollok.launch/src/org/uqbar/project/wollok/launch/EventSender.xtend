package org.uqbar.project.wollok.launch

import org.uqbar.project.wollok.launch.io.CommunicationChannel
import org.uqbar.project.wollok.ui.debugger.server.AbstractCommunicationHandlerRunnable
import org.uqbar.project.wollok.ui.debugger.server.XTextInterpreterEventPublisher

import static org.uqbar.project.wollok.ui.debugger.WollokDebugCommands.*

/**
 * Gateway that handles communication with the client debugger.
 * It implements the interfeace XTextInterpreterEventPublisher that the interpreter
 * uses to publish events.
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
		//ojo, sin el this no anda. Parece un bug en xtend
		this.sendEvent(EVENT_SUSPENDED_BREAKPOINT, fileName, lineNumber)
	}
	
}