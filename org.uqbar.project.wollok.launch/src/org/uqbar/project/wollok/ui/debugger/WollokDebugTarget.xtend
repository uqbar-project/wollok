package org.uqbar.project.wollok.ui.debugger

import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.eclipse.core.resources.IMarkerDelta
import org.eclipse.core.runtime.CoreException
import org.eclipse.debug.core.DebugEvent
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.model.IBreakpoint
import org.eclipse.debug.core.model.IDebugTarget
import org.eclipse.debug.core.model.ILineBreakpoint
import org.eclipse.debug.core.model.IProcess
import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.debug.core.model.IThread
import org.uqbar.project.wollok.launch.WollokLaunchConstants
import org.uqbar.project.wollok.ui.debugger.client.EventDispatchJob
import org.uqbar.project.wollok.ui.debugger.model.WollokDebugElement
import org.uqbar.project.wollok.ui.debugger.model.WollokStackFrame
import org.uqbar.project.wollok.ui.debugger.model.WollokThread
import org.uqbar.project.wollok.ui.debugger.server.rmi.DebugCommandHandler
import org.uqbar.project.wollok.ui.debugger.server.rmi.XDebugStackFrame

import static org.uqbar.project.wollok.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.launch.shortcut.WDebugExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * @author jfernandes
 */
class WollokDebugTarget extends WollokDebugElement implements IDebugTarget {
	protected String name
	private IProcess process
	protected ILaunch launch
	
	//commands
	Client client
	DebugCommandHandler commandHandler
	// events
	EventDispatchJob eventHandler
	
	protected boolean suspended = true
	protected boolean fTerminated = false
	
	protected WollokThread wollokThread
	private IThread[] wollokThreads
	
	new(ILaunch launch, IProcess process, int requestPort, int eventPort) throws CoreException {
		super(null)
		this.launch = launch
		target = this
		this.process = process
		
		// el orden importa! hace dos conexiones
		commandHandler = createCommandHandler(requestPort) 
		eventHandler = new EventDispatchJob(this, eventPort)
		
		wollokThread = new WollokThread(this)
		wollokThreads = #[wollokThread]
		eventHandler.schedule
		breakpointManager.addBreakpointListener(this)
	}
	
	def createCommandHandler(int port) {
		Thread.sleep(2500) // wait for remote process to start the server
		client = new Client("localhost", port, new CallHandler)
		client.getGlobal(DebugCommandHandler) as DebugCommandHandler
	}
	
	override getName() throws DebugException {
		if (name == null) {
			name = "Wollok Program"
			try
				name = launch.launchConfiguration.getMain
			catch (CoreException e) {
			}
		}
		name
	}
	
	override getProcess() { process }
	override ILaunch getLaunch() { launch } 
	override getThreads() throws DebugException { wollokThreads }
	override hasThreads() throws DebugException {	true }
	def getWThread() throws DebugException { wollokThread }
	
	override supportsBreakpoint(IBreakpoint breakpoint) {
		if (breakpoint.isWollokBreakpoint) {
			val marker = breakpoint.marker
			if (marker != null)
				return marker.resource.fileExtension == WollokLaunchConstants.EXTENSION
		}
		false
	}
	
	override canTerminate() { process.canTerminate }
	override isTerminated() { process.terminated }
	override isSuspended() { suspended }
	override canResume() { !isTerminated && suspended }
	override canSuspend() { !isTerminated && !suspended }
	
	// commands
	override terminate() throws DebugException { commandHandler.exit  }	
	override resume() throws DebugException { commandHandler.resume }
	override suspend() throws DebugException { commandHandler.pause }
	
	def void stepOver() { commandHandler.stepOver }
	def void stepInto() { commandHandler.stepInto }
	def void stepReturn() { commandHandler.stepReturn }
	
	def IStackFrame[] getStackFrames() throws DebugException {
		commandHandler.stackFrames.map[i, f| f.toIStackFrame(i)].toList.reverse
	}
	
	def toIStackFrame(XDebugStackFrame frame, int index) {
		new WollokStackFrame(WThread, frame, index, commandHandler)
	}

	// *************************	
	// ** breakpoint listener
	// *************************	
	
	override breakpointChanged(IBreakpoint breakpoint, IMarkerDelta delta) {
		if (supportsBreakpoint(breakpoint))
			if (breakpoint.enabled)
				breakpointAdded(breakpoint)
			else
				breakpointRemoved(breakpoint, null)
	}
	
	override breakpointAdded(IBreakpoint breakpoint) {
		if (supportsBreakpoint(breakpoint) && breakpoint.enabled)
			commandHandler.setBreakpoint(breakpoint.fileURI, (breakpoint as ILineBreakpoint).lineNumber)
			
	}
	
	override breakpointRemoved(IBreakpoint breakpoint, IMarkerDelta delta) {
		if (supportsBreakpoint(breakpoint))
			commandHandler.clearBreakpoint(breakpoint.fileURI, (breakpoint as ILineBreakpoint).lineNumber)
	}
	
	override canDisconnect() { false }
	override disconnect() throws DebugException {}
	override isDisconnected() { false }
	override getMemoryBlock(long startAddress, long length) throws DebugException { null }
	override supportsStorageRetrieval() { false }

	// *************************	
	// ** notifications
	// *************************
	
	def started() {
		fireCreationEvent
		installDeferredBreakpoints
		try
			resume
		catch (DebugException e)
			e.printStackTrace
	}
	
	def private void installDeferredBreakpoints() {
		breakpoints.forEach[breakpointAdded(it)]
	}
	
	def getBreakpoints() { ID_DEBUG_MODEL.getBreakpoints }
	
	def resumed(int detail) {
		suspended = false
		wollokThread.fireResumeEvent(detail)
	}
	def suspended(int detail) {
		suspended = true
		wollokThread.fireSuspendEvent(detail)
	}
	def terminated() {
		client.close
		fTerminated = true
		suspended = false
		breakpointManager.removeBreakpointListener(this)
		fireTerminateEvent
	}
	
	def breakpointHit(String fileURI, int lineNumber) {
		findAndSetCurrentBreakpoint(fileURI, lineNumber)
		suspended(DebugEvent.BREAKPOINT);
	}
	
	def findAndSetCurrentBreakpoint(String fileURI, int lineNumber) {
		breakpoints //
			.filter[supportsBreakpoint] //
			.filter(ILineBreakpoint) //
			.findFirstAndDo([marker.resource.locationURI == fileURI && it.lineNumber == lineNumber], [ //
				wollokThread.setBreakpoints(#[it]) //
			]) //
	}

	def getRemoteInterpreter() { commandHandler }
	
	override toString() { "Wollok Target" }
	
}