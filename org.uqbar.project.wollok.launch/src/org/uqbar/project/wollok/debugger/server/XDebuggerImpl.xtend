package org.uqbar.project.wollok.debugger.server

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.debugger.server.out.XTextInterpreterEventPublisher
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.api.XInterpreter

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * xdebugger implementation that actually
 * is connected to a remote debugger.
 * 
 * @author jfernandes
 */
class XDebuggerImpl implements XDebugger {
	static Logger log = Logger.getLogger(XDebuggerImpl)
	XInterpreter<?> interpreter
	var XTextInterpreterEventPublisher eventSender
	val breakpoints = <XBreakpoint>newArrayList 
	val Object suspendedLock = new Object
	EObject currentStepObject
	XBreakpoint lastBreakpointHit
	XDebuggerState state = new RunThroughDebuggerState
	
	def void setInterpreter(XInterpreter<?> interpreter) { this.interpreter = interpreter }
	def void setEventSender(XTextInterpreterEventPublisher eventSender) { this.eventSender = eventSender }
	
	def void setState(XDebuggerState state) { this.state = state }
	
	// methods

	/**
	 * Send started event, then wait paused for the debugger to install breakpoints and perform initialization.
	 * He will call us the "resume" command once he's ready.
	 */	
	override started() { 
		eventSender.started
		sleep
	}
	
	override aboutToEvaluate(EObject element) {
		currentStepObject = element
		logEvent("BEFORE", element)
		state.before(this, element)
		checkBreakpointsAndSuspendIfHit(element)
	}
	
	protected def logEvent(String event, EObject element) {
		log.trace('''ON STATE [«state»] «event» [«element.fileURI.lastSegment»:«element.lineNumber» - id=«System.identityHashCode(currentStepObject)»]: «element.shortSourceCode»''')
	}
	
	override evaluated(EObject element) {
		logEvent("AFTER", element)
		state.after(this, element)
		currentStepObject = null
	}
	
	override terminated() { eventSender.terminated }
	
	// helper methods
	
	def checkBreakpointsAndSuspendIfHit(EObject element) {
		val bp = breakpoints.findFirst[hits(element)]
		if (bp != null && bp != lastBreakpointHit) {
			eventSender.breakpointHit(bp.fileURI, bp.lineNumber)
			lastBreakpointHit = bp
			sleep
		}
	}
	
	protected def sleep() {
		eventSender.suspendStep
		synchronized(suspendedLock) {
			suspendedLock.wait
		}
		eventSender.resumeStep
	}
	
	protected def wakeUp() {
		synchronized(suspendedLock) { 
			suspendedLock.notify
		}
	} 
	
	// ***********************************
	// ** metodos llamados por comandos
	// ***********************************
	
	override getStack() { interpreter.stack }
	
	override setBreakpoint(String fileURI, int line) { breakpoints.add(new XBreakpoint(fileURI, line)) }
	override clearBreakpoint(String fileURI, int line) {
		val bp = breakpoints.findFirst[it.fileURI == fileURI && it.lineNumber == line]
		if (bp != null)
			breakpoints.remove(bp)
	}
	
	override resume() {
		state = new RunThroughDebuggerState
		wakeUp
	}
	
	override stepOver() {
		state = new SteppingOver(currentStepObject)
		wakeUp
	}
	
	override stepInto() {
		state = new PauseOnNext
		wakeUp
	}
	
	override stepReturn() {
		state = new SteppingOut(stack.size)
		wakeUp
	}
	
	override pause() { state = new PauseOnNext }
	
	override terminate() {
		log.info("Terminating due to debugger request !")
		eventSender.terminated
		System.exit(0)
	}

}