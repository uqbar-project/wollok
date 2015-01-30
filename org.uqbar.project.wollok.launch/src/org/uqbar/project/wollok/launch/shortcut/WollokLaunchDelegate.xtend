package org.uqbar.project.wollok.launch.shortcut

import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.debug.core.DebugEvent
import org.eclipse.debug.core.DebugPlugin
import org.eclipse.debug.core.IDebugEventSetListener
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.IProcess
import org.eclipse.jdt.launching.JavaLaunchDelegate
import org.uqbar.project.wollok.ui.debugger.WollokDebugTarget

import static org.uqbar.project.wollok.launch.io.IOUtils.*

import static extension org.uqbar.project.wollok.launch.shortcut.WDebugExtensions.*
import org.uqbar.project.wollok.launch.WollokLauncher
import static extension org.uqbar.project.wollok.launch.WollokLaunchConstants.*


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

	//Use RefreshUtil after switching to debug >= 3.6
	private static final String ATTR_REFRESH_SCOPE = DebugPlugin.getUniqueIdentifier() + ".ATTR_REFRESH_SCOPE";

	override launch(ILaunchConfiguration configuration, String mode, ILaunch launch, IProgressMonitor monitor) throws CoreException {
		if (configuration.getAttribute(ATTR_REFRESH_SCOPE, null as String) != null) {
			DebugPlugin.getDefault.addDebugEventListener(createListener(configuration))
		}
		var config = configuration.setDebugWollokParam(mode)
		super.launch(config, mode, launch, monitor);
		
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
	
	def setDebugWollokParam(ILaunchConfiguration config, String mode) {
		if (mode.isDebug) {
			val requestPort = findFreePort
			val eventPort = findFreePort
			config.getWorkingCopy =>[
				setCommandPort(requestPort)
				setEventPort(eventPort)
				setOrUpdateDebugWollokPorts(buildDebugProgramArguments(requestPort, eventPort))
				doSave
			]
		}
		else {
			config.removeDebugParamIfExists
		}
	}
	
	
	/** 
	 * It could be an already ran configuration so we need to replace the ports
	 * Otherwise just add them
	 */
	def setOrUpdateDebugWollokPorts(ILaunchConfiguration config, String newDebugParam) {
		val args = config.programArguments
		val index = args.indexOf(WollokLauncher.DEBUG_PORTS_PARAM)
		if (index > 0)
			config.programArguments = args.substring(0, index) + newDebugParam
		else 
			config.programArguments = args + " " + newDebugParam
	}
	
	def removeDebugParamIfExists(ILaunchConfiguration config) {
		val args = config.programArguments
		val index = args.indexOf(WollokLauncher.DEBUG_PORTS_PARAM)
		if (index > 0) 
			config.programArguments = args.substring(0, index)
		else
			config
	}
	
	def createWollokTarget(ILaunch launch, int requestPort, int eventPort) {
		new WollokDebugTarget(launch, launch.processes.get(0), requestPort, eventPort)
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
		}
	}
	
	def buildDebugProgramArguments(int requestPort, int eventPort) {
		WollokLauncher.DEBUG_PORTS_PARAM + requestPort + WollokLauncher.DEBUG_PORTS_PARAM_SEPARATOR + eventPort 
	}

}
