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
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.console.ConsolePlugin
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.debugger.WollokDebugTarget
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.ui.console.WollokReplConsole
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.preferences.WollokNumbersConfigurationBlock

import static org.uqbar.project.wollok.launch.io.IOUtils.*

import static extension org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*
import static extension org.uqbar.project.wollok.ui.launch.shortcut.LauncherExtensions.*
import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import static extension org.uqbar.project.wollok.ui.launch.extensions.WollokConsoleExtensions.*

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

	// Use RefreshUtil after switching to debug >= 3.6
	private static final String ATTR_REFRESH_SCOPE = DebugPlugin.getUniqueIdentifier() + ".ATTR_REFRESH_SCOPE";

	override launch(ILaunchConfiguration configuration, String mode, ILaunch launch,
		IProgressMonitor monitor) throws CoreException {

		configuration.activateDynamicDiagramIfNeeded(preferenceStoreAccess)

		if (mode.isDebug && configuration.getAttribute(ATTR_REFRESH_SCOPE, null as String) !== null) {
			DebugPlugin.getDefault.addDebugEventListener(createListener(configuration))
		}

		val config = configuration.configureLaunchSettings(mode)
		super.launch(config, mode, launch, monitor)

		if (configuration.hasRepl) {
			val consoleManager = ConsolePlugin.getDefault().consoleManager
			consoleManager.consoles.forEach [ shutdown ]
			consoleManager.removeConsoles(consoleManager.consoles)
			val console = new WollokReplConsole
			consoleManager.addConsoles(#[console])
			console.startForProcess(launch.processes.get(0))
		}

		if (mode.isDebug) {
			try {
				launch.removeDebugTarget(launch.debugTarget)
				launch.addDebugTarget(createWollokTarget(launch, config.commandPort, config.getEventPort))
			} catch (RuntimeException e) {
				launch.terminate
				abort(WollokLaunchUIMessages.WollokDebugger_GENERAL_ERROR_MESSAGE, e, DebugPlugin.INTERNAL_ERROR)
			}
		}
	}

	def configureLaunchSettings(ILaunchConfiguration configuration, String mode) {
		val result = configuration.getWorkingCopy
		result.setAttribute(ATTR_WOLLOK_DYNAMIC_DIAGRAM, preferenceStoreAccess.dynamicDiagramActivated)
		if (mode.isDebug) {
			val requestPort = findFreePort
			val eventPort = findFreePort
			result => [
				setCommandPort(requestPort)
				setEventPort(eventPort)
				setArguments(requestPort, eventPort)
				doSave
			]
		} else {
			result => [
				setArguments(0, 0)
				doSave
			]
		}
	}

	def configureLaunchParameters(ILaunchConfiguration config, int requestPort, int eventPort) {
		val parameters = new WollokLauncherParameters
		parameters.eventsPort = eventPort
		parameters.requestsPort = requestPort
		parameters.wollokFiles += config.wollokFile
		parameters.severalFiles = config.severalFiles
		parameters.folder = config.folder
		parameters.hasRepl = config.hasRepl
		parameters.validate = config.hasRepl // Validate when the user enters code in the REPL.
		parameters.dynamicDiagramActivated = preferenceStoreAccess.dynamicDiagramActivated
		parameters.libraries = config.libraries

		if (config.hasRepl && preferenceStoreAccess.dynamicDiagramActivated) {
			parameters.dynamicDiagramPort = Activator.getDefault.wollokDynamicDiagramListeningPort
		}

		configureNumberPreferences(parameters)

		parameters
	}

	def configureNumberPreferences(WollokLauncherParameters parameters) {
		if (preferenceStoreAccess.preferenceStore.contains(WollokNumbersConfigurationBlock.DECIMAL_POSITIONS))
			parameters.numberOfDecimals = preferenceStoreAccess.preferenceStore.getInt(
				WollokNumbersConfigurationBlock.DECIMAL_POSITIONS)

		if (preferenceStoreAccess.preferenceStore.contains(WollokNumbersConfigurationBlock.NUMBER_COERCING_STRATEGY))
			parameters.coercingStrategy = preferenceStoreAccess.preferenceStore.getString(
				WollokNumbersConfigurationBlock.NUMBER_COERCING_STRATEGY)

		if (preferenceStoreAccess.preferenceStore.contains(WollokNumbersConfigurationBlock.NUMBER_PRINTING_STRATEGY))
			parameters.printingStrategy = preferenceStoreAccess.preferenceStore.getString(
				WollokNumbersConfigurationBlock.NUMBER_PRINTING_STRATEGY)
	}

	def setArguments(ILaunchConfiguration config, int requestPort, int eventPort) {
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
			} else if (event.isStarted) {
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
