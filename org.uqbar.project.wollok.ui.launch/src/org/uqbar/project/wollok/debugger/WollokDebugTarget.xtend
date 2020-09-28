package org.uqbar.project.wollok.debugger

import java.net.ConnectException
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import net.sf.lipermi.net.Server
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
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.debugger.model.WollokDebugElement
import org.uqbar.project.wollok.debugger.model.WollokStackFrame
import org.uqbar.project.wollok.debugger.model.WollokThread
import org.uqbar.project.wollok.debugger.server.out.XTextInterpreterEventPublisher
import org.uqbar.project.wollok.debugger.server.rmi.DebugCommandHandler
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants
import org.uqbar.project.wollok.ui.preferences.WollokRootPreferencePage

import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * This is probably the main class of the debugger client side (UI).
 * It implements eclipse's interface.
 * It receives the event from the remote VM (when it gets suspended, resumed, finished, breakpoint hit etc)
 * 
 * @author jfernandes
 */
class WollokDebugTarget extends WollokDebugElement implements IDebugTarget {
	protected String name
	IProcess process
	protected ILaunch launch
	
	// commands
	Client client
	DebugCommandHandler commandHandler
	// events
	Server server
	
	protected boolean suspended = true
	protected boolean fTerminated = false
	
	protected WollokThread wollokThread
	IThread[] wollokThreads
	
	IPreferenceStore prefs
	
	new(IPreferenceStoreAccess preferenceStoreAccess, ILaunch launch, IProcess process, int requestPort, int eventPort) throws CoreException {
		super(null)
		this.prefs = preferenceStoreAccess.preferenceStore
		this.launch = launch
		this.target = this
		this.process = process
		
		wollokThread = new WollokThread(this)
		wollokThreads = #[wollokThread]
		
		// Order matters ! there are two connections !

		// UI <- VM (events)
		server = listenForVM(eventPort)
		
		// UI -> VM (orders)
		commandHandler = connectToVM(requestPort)
		
		breakpointManager.addBreakpointListener(this)
		
		// start VM execution !
		commandHandler.clientReady
	}
	
	def connectToVM(int port) {
		var retries = 1
		do {
			try {
				Thread.sleep(sleepTime)
				client = new Client("localhost", port, new CallHandler)
				return client.getGlobal(DebugCommandHandler) as DebugCommandHandler
			}
			catch (ConnectException e) {
				retries++
			}
		} while (retries < 4)
		
		throw new WollokRuntimeException("Could NOT connect to Wollok VM !")
	}
	
	def listenForVM(int port) {
		new Server => [
			bind(port, new CallHandler => [
				registerGlobal(XTextInterpreterEventPublisher, new DebuggerUIInterpreterEventListener(this))
			])	
		]
	}
	
	def getSleepTime() {
		if (prefs.contains(WollokRootPreferencePage.DEBUGGER_WAIT_TIME_FOR_CONNECT))
			prefs.getInt(WollokRootPreferencePage.DEBUGGER_WAIT_TIME_FOR_CONNECT)
		else {
			WollokRootPreferencePage.DEBUGGER_WAIT_TIME_FOR_CONNECT_DEFAULT
		}
	}
	
	override getName() throws DebugException {
		if (name === null) {
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
	override hasThreads() throws DebugException { true }
	def getWThread() throws DebugException { wollokThread }
	
	override supportsBreakpoint(IBreakpoint breakpoint) {
		if (breakpoint.isWollokBreakpoint) {
			val marker = breakpoint.marker
			if (marker !== null)
				return WollokLaunchConstants.isWollokFileExtension(marker.resource.fileExtension)
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
	
	var IStackFrame[] stackCache = null
	
	def synchronized IStackFrame[] getStackFrames() throws DebugException {
		if (stackCache === null) {
			stackCache = commandHandler.stackFrames.map[i, f| f.toIStackFrame(i) ].toList.reverse
		}
		stackCache
	}
	
	def toIStackFrame(XDebugStackFrame frame, int index) {
		new WollokStackFrame(WThread, frame, index)
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
		stackCache = null
		suspended = false
		wollokThread.fireResumeEvent(detail)
	}
	def suspended(int detail) {
		suspended = true
		wollokThread.fireSuspendEvent(detail)
	}
	def terminated() {
		stackCache = null
		
		client.close
		server.close
		
		fTerminated = true
		suspended = false
		breakpointManager.removeBreakpointListener(this)
		fireTerminateEvent
	}
	
	def breakpointHit(String fileURI, int lineNumber) {
		stackCache = null
		findAndSetCurrentBreakpoint(fileURI, lineNumber)
		suspended(DebugEvent.BREAKPOINT)
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