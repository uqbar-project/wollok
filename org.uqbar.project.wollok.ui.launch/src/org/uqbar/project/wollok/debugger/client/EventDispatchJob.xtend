package org.uqbar.project.wollok.debugger.client

import java.io.BufferedReader
import java.io.IOException
import java.net.Socket
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.debug.core.DebugEvent
import org.uqbar.project.wollok.debugger.WollokDebugTarget
import org.uqbar.project.wollok.debugger.client.HandlesEvent
import org.uqbar.project.wollok.debugger.client.XDebuggerException

import static org.uqbar.project.wollok.debugger.WollokDebugCommands.*

import static extension org.uqbar.project.wollok.launch.io.IOUtils.*

/**
 * Listens to events from the VM and fires corresponding debug events.
 * 
 * @see HandleCommandDebugThread for the counter part in the server (interpreter/VM)
 * 
 * @author jfernandes
 */
 // RENAME: EventHandler
class EventDispatchJob extends Job {
	extension WollokDebugTarget target
	Socket socket
	BufferedReader in

	new(WollokDebugTarget target, int eventPort) {
		super("WDebug Events Listener");
		this.target = target
		system = true
		
		Thread.sleep(1000) // wait for process to setup the socket
		socket = createClientSocket(eventPort)
		in = socket.reader 
	}

	override run(IProgressMonitor monitor) {
		while (!isTerminated) {
			try {
				val event = in.readLine				
				if (event != null) {
					WThread.breakpoints = null
					WThread.stepping = false
					handleEvent(event)
				}
			} catch (IOException e) {
				terminated()
			}
		}
		Status.OK_STATUS
	}
	
	def handleEvent(String event) {
		// hardcoded !
		if (event.startsWith(EVENT_SUSPENDED_BREAKPOINT))
			handleSuspendedBreakpoint(event)
		else 
			findHandler(event).invoke(this)		
	}
	
	def findHandler(String event) {
		val m = getClass.methods.findFirst[m| m.isAnnotationPresent(HandlesEvent) && m.getAnnotation(HandlesEvent).value == event]
		if (m == null)
			throw new XDebuggerException("Unkwon remote event: " + event)
		m
	}
	
	def handleSuspendedBreakpoint(String event) {
		val tokens = event.split(' ') // 'suspended' 'breakpoint' paramFile paramLine
		val fileName = tokens.get(2)
		val lineNumber = Integer.parseInt(tokens.get(3))
		breakpointHit(fileName, lineNumber)
	}
	
	// ****************************************
	// ** communication protocal handlers
	// ****************************************
	
	@HandlesEvent(EVENT_STARTED)
	def handleStarted() { started }
	
	@HandlesEvent(EVENT_TERMINATED)
	def handleTerminated() { terminated() }
	
	@HandlesEvent(EVENT_RESUMED_STEP)
	def handleResumedStep() { 
		WThread.stepping = true
		resumed(DebugEvent.STEP_OVER)
	}
	
	@HandlesEvent("resumed client")
	def handleResumedClient() { resumed(DebugEvent.CLIENT_REQUEST) }
	
	@HandlesEvent("suspended client")
	def handleSuspendedClient() { suspended(DebugEvent.CLIENT_REQUEST) }
	
	@HandlesEvent(EVENT_SUSPENDED_STEP)
	def handleSuspendedStep() { suspended(DebugEvent.STEP_END) }

}