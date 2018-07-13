package org.uqbar.project.wollok.debugger.model

import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.debug.core.model.IVariable
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.debugger.WollokDebugTarget
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable

/**
 * Debugger model object representing a remote stack frame.
 * 
 * @author jfernandes
 */
class WollokStackFrame extends WollokDebugElement implements IStackFrame {
	private WollokThread thread
	private int id
	XDebugStackFrame frame
	private IVariable[] variables = #[]
	// uris are not serializable
	private transient URI uri  
	
	new(WollokThread thread, XDebugStackFrame frame, int id) {
		super(thread.debugTarget)
		this.id = id
		this.thread = thread
		this.frame = frame
		
		variables = frame.variables.map[toEclipseVariable(target)]
	}
	
	def static toEclipseVariable(XDebugStackFrameVariable variable, WollokDebugTarget target) { new WollokVariable(target, variable) }
	
	def getIdentifier() { id }
	override getThread() { thread }
	override getName() throws DebugException {
		val fileInfo = fileURI.lastSegment +  ":" + lineNumber
		if (frame.sourceLocation.contextDescription !== null)
			frame.sourceLocation.contextDescription + " (" + fileInfo + ")"
		 else
		 	fileInfo 
	}

	// source code

	def String getSourceName() { fileURI.lastSegment }
 	def synchronized URI getFileURI() { 
 		if (uri === null)
 			uri = URI.createURI(frame.sourceLocation.fileURI)
 		uri
 	}	
	override getLineNumber() throws DebugException { frame.sourceLocation.startLine }	
	override getCharStart() throws DebugException { frame.sourceLocation.offset }
	override getCharEnd() throws DebugException { frame.sourceLocation.offset + frame.sourceLocation.length }
	
	override getVariables() throws DebugException { variables }
	override hasVariables() throws DebugException { variables.length > 0 }

	// delegated to thread	
	override canStepInto() { thread.canStepInto }
	override canStepOver() { thread.canStepOver }
	override canStepReturn() { thread.canStepReturn }
	override isStepping() { thread.stepping }
	override stepInto() throws DebugException { thread.stepInto }
	override stepOver() throws DebugException { thread.stepOver }
	override stepReturn() throws DebugException { thread.stepReturn }
	override canResume() { thread.canResume }
	override canSuspend() { thread.canSuspend }
	override isSuspended() { thread.suspended }
	override resume() throws DebugException { thread.resume }
	override suspend() throws DebugException { thread.suspend }
	override canTerminate() { thread.canTerminate }
	override isTerminated() { thread.terminated }
	override terminate() throws DebugException { thread.terminate }
	
	// not implemented
	
	override getRegisterGroups() throws DebugException { null }
 	override hasRegisterGroups() throws DebugException { false }
 	
 	override toString() { name }
 	
 	override equals(Object obj) {
		if (obj instanceof WollokStackFrame) {
			try {
				return obj.sourceName == sourceName &&
					obj.lineNumber == lineNumber &&
					obj.id == id;
			} catch (DebugException e) {
				e.printStackTrace
			}
		}
		return false
	}
	
	override hashCode() { sourceName.hashCode - lineNumber  + id }
	
}