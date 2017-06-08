package org.uqbar.project.wollok.ui.launch.shortcut

import com.google.inject.Inject
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.debug.core.DebugEvent
import org.eclipse.debug.core.DebugPlugin
import org.eclipse.debug.core.IDebugEventSetListener
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.IProcess
import org.eclipse.jdt.launching.JavaLaunchDelegate
import org.eclipse.ui.console.ConsolePlugin
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.debugger.WollokDebugTarget
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.ui.console.WollokReplConsole

import static org.uqbar.project.wollok.launch.io.IOUtils.*

import static extension org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*
import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import org.eclipse.ui.PlatformUI

/**
 * Launches the process to execute the interpreter.
 * As the interpreter is written in Java, it extends JavaLaunchDelegate in order
 * to reuse a lot of code that starts up a JVM etc (see superclass).
 * 
 * But then it removes the Java "Debug Target" and adds our own (WollokDebugTarget),
 * in order to hide away all the java debugging and just provide our own entities (stack, threads, etc).
 * 
 * @author jfernandes
 */
class WollokLaunchDelegate extends JavaLaunchDelegate {
	@Inject
	IPreferenceStoreAccess preferenceStoreAccess

	//Use RefreshUtil after switching to debug >= 3.6
	private static final String ATTR_REFRESH_SCOPE = DebugPlugin.getUniqueIdentifier() + ".ATTR_REFRESH_SCOPE";

	override launch(ILaunchConfiguration configuration, String mode, ILaunch launch, IProgressMonitor monitor) throws CoreException {
		if (mode.isDebug && configuration.getAttribute(ATTR_REFRESH_SCOPE, null as String) != null) {
			DebugPlugin.getDefault.addDebugEventListener(createListener(configuration))
		}
		var config = configuration.configureLaunchSettings(mode)
		super.launch(config, mode, launch, monitor)
		
		if (configuration.hasRepl) {
			val consoleManager = ConsolePlugin.getDefault().consoleManager
			var console = consoleManager.consoles.findFirst[ name == WollokReplConsole.consoleName ] as WollokReplConsole
			if (console == null) {
				console = new WollokReplConsole
				consoleManager.addConsoles(#[console])
			}
			console.startForProcess(launch.processes.get(0))
		}
		
		if (mode.isDebug) {
			try {
				launch.removeDebugTarget(launch.debugTarget)
				launch.addDebugTarget(createWollokTarget(launch, config.commandPort, config.getEventPort))
			}
			catch (RuntimeException e) {
				launch.terminate
				abort("Could not connect to remote process", e, DebugPlugin.INTERNAL_ERROR)
			}
		}
	}
	
	def configureLaunchSettings(ILaunchConfiguration config, String mode) {
		if (mode.isDebug) {
			val requestPort = findFreePort
			val eventPort = findFreePort
			config.getWorkingCopy =>[
				setCommandPort(requestPort)
				setEventPort(eventPort)
				setArguments(requestPort, eventPort)
				doSave
			]
		}else{
			config.getWorkingCopy => [
				setArguments(0, 0)
				doSave
			]
		}
	}
	
	def configureLaunchParameters(ILaunchConfiguration config, int requestPort, int eventPort){
		val parameters = new WollokLauncherParameters
		parameters.eventsPort = eventPort
		parameters.requestsPort = requestPort
		parameters.wollokFiles += config.wollokFile
		parameters.hasRepl = config.hasRepl
		parameters
	}
	
	def setArguments(ILaunchConfiguration config, int requestPort, int eventPort){
		config.programArguments = configureLaunchParameters(config, requestPort, eventPort).build
	}
	
	def createWollokTarget(ILaunch launch, int requestPort, int eventPort) {
		new WollokDebugTarget(preferenceStoreAccess, launch, launch.processes.get(0), requestPort, eventPort)
	}
	
	def createListener(ILaunchConfiguration configuration) {
		new IDebugEventSetListener() {
			override handleDebugEvents(DebugEvent[] events) {
				handleEvents(this, configuration, events)
			}
		}
	}

	def handleEvents(IDebugEventSetListener listener, ILaunchConfiguration configuration, DebugEvent[] events) {
		for (event : events) {
			if (event.isTerminate) {
				val process = event.source as IProcess
				if (configuration == process.launch.launchConfiguration) {
					DebugPlugin.getDefault.removeDebugEventListener(listener);
					refreshJob(configuration).schedule
					return
				}
			}
			else if (event.isStarted) {
				openDebugPerspective
			}
		}
	}
	
	def openDebugPerspective() {
		PlatformUI.workbench => [
			showPerspective("org.eclipse.debug.ui.DebugPerspective", activeWorkbenchWindow)
		]
	}
	
}
