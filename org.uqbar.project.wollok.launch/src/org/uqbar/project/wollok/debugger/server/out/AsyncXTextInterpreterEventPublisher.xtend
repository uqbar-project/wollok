package org.uqbar.project.wollok.debugger.server.out

import org.uqbar.project.wollok.debugger.server.out.XTextInterpreterEventPublisher
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Wraps another XTextInterpreterEventPublisher to send the methods
 * in another thread (asynchronous)
 * 
 * This simulates the threading model of a real debugging session, where 
 * the interpreter uses EventSender which sends the event "over the wire".
 * 
 * @author jfernandes
 */
class AsyncXTextInterpreterEventPublisher implements XTextInterpreterEventPublisher {
	XTextInterpreterEventPublisher wrapped;
	ExecutorService service = Executors.newFixedThreadPool(1)
	
	new(XTextInterpreterEventPublisher wrapped) {
		this.wrapped = wrapped
	}
	
	override started() {
		async [ wrapped.started ]
	}
	
	override terminated() {
		async [ wrapped.terminated ]
	}
	
	override suspendStep() {
		async [ wrapped.suspendStep ]
	}
	
	override resumeStep() {
		async [ wrapped.resumeStep ]
	}
	
	override breakpointHit(String fileName, int lineNumber) {
		async [ wrapped.breakpointHit(fileName, lineNumber) ]
	}
	
	protected def async(Runnable r) {
		if (!service.isShutdown)
			service.execute(r)
	}
	
	def close() {
		service.shutdown()
	}
	
}