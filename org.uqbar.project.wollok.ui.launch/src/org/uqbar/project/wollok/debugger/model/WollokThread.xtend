package org.uqbar.project.wollok.debugger.model

import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IBreakpoint
import org.eclipse.debug.core.model.IThread
import org.uqbar.project.wollok.debugger.model.WollokDebugElement
import org.uqbar.project.wollok.debugger.WollokDebugTarget

/**
 * @author jfernandes
 */
class WollokThread extends WollokDebugElement implements IThread {
	/** Breakpoints this thread is suspended at or <code>null</code> if none. */
	private IBreakpoint[] breakpoints
	private boolean fStepping = false
	
	new(WollokDebugTarget target) {
		super(target)
	}
	
	override getStackFrames() throws DebugException {
		if (suspended) debugTarget.stackFrames else #[]
	}
	
	override getBreakpoints() { if (breakpoints == null) #[] else breakpoints }
	
	override getName() throws DebugException { "Thread[1]" }
	override getPriority() throws DebugException { 0 }
	
	override getTopStackFrame() throws DebugException {
		val frames = getStackFrames
		if (frames.length > 0) frames.get(0) else null
	}
	
	override hasStackFrames() throws DebugException { suspended }
	
	override canResume() { suspended }
	override canSuspend() { !suspended }
	override isSuspended() { debugTarget.suspended }
	override suspend() throws DebugException { debugTarget.suspend }
	override resume() throws DebugException { debugTarget.resume }
	
	override isStepping() { fStepping }
	
 	override stepOver() throws DebugException { debugTarget.stepOver }
 	override canStepOver() { suspended }
 	
	override stepInto() throws DebugException { debugTarget.stepInto }
	override canStepInto() { suspended }
	
	override stepReturn() throws DebugException { debugTarget.stepReturn }
	override canStepReturn() { suspended && stackFrames.length > 1 }
	
	override canTerminate() { !terminated }
	override isTerminated() { debugTarget.isTerminated }
	override terminate() throws DebugException { debugTarget.terminate }

	def void setBreakpoints(IBreakpoint[] breakpoints) { this.breakpoints = breakpoints }
	def void setStepping(boolean stepping) { fStepping = stepping 	}
	
	override toString() { "Main Thread" }

	// not implemented yet
	
}