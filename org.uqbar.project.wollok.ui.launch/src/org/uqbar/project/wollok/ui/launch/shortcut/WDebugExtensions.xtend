package org.uqbar.project.wollok.ui.launch.shortcut

import org.apache.log4j.Logger
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.debug.core.DebugEvent
import org.eclipse.debug.core.DebugPlugin
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.ILaunchManager
import org.eclipse.debug.core.model.IBreakpoint
import org.eclipse.debug.core.model.ILineBreakpoint
import org.eclipse.debug.core.model.IProcess
import org.eclipse.debug.ui.DebugUITools
import org.eclipse.debug.ui.RefreshTab
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants

import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.*

/**
 * @author jfernandes
 */
class WDebugExtensions {
	private static final Logger logger = Logger.getLogger(WDebugExtensions)
	
	def static isWollokBreakpoint(IBreakpoint b) { b.modelIdentifier == WollokLaunchConstants.ID_DEBUG_MODEL }
	
	def static isTerminate(DebugEvent e) {
		e.source instanceof IProcess && e.kind == DebugEvent.TERMINATE
	}
	
	def static isStarted(DebugEvent e) {
		e.source instanceof IProcess && e.kind == DebugEvent.CREATE
	}
	
	// fire events
	
	def static void fireEvent(DebugEvent event) { DebugPlugin.getDefault.fireDebugEventSet(#[event]) }
	def static void fireEvent(Object source, int eventType) { fireEvent(new DebugEvent(source, eventType)) }
	def static void fireEvent(Object source, int eventType, int detail) { fireEvent(new DebugEvent(source, eventType, detail)) }
	
	def static isDebug(String mode) { mode.equals(ILaunchManager.DEBUG_MODE) }
	def static hasRepl(ILaunchConfiguration configuration){
		configuration.getAttribute(WollokLaunchConstants.ATTR_WOLLOK_IS_REPL, false)	
	}
	
	def static libraries(ILaunchConfiguration configuration) {
		configuration.getAttribute(WollokLaunchConstants.ATTR_WOLLOK_LIBS, #[])			
	}
	
	def static setProgramArguments(ILaunchConfiguration configuration, String newValue) {
		val wc = configuration.getWorkingCopy
		wc.setAttribute(ATTR_PROGRAM_ARGUMENTS, newValue)
		wc.doSave
		wc
	}
	
	def static addProgramArgument(ILaunchConfiguration configuration, String newValue) {
		val wc = configuration.getWorkingCopy
		wc.setAttribute(ATTR_PROGRAM_ARGUMENTS, configuration.programArguments + " " + newValue)
		wc.doSave
	}
	
	def static getProgramArguments(ILaunchConfiguration configuration) {
		configuration.getAttribute(ATTR_PROGRAM_ARGUMENTS, "")
	}
	
	def static getMain(ILaunchConfiguration configuration) {
		configuration.getMain("Wollok VM")
	}
	
	def static getMain(ILaunchConfiguration configuration, String defaultValue) {
		configuration.getAttribute(ATTR_MAIN_TYPE_NAME, defaultValue);
	}
	
	def static getBreakpoints(String debugModel) {
		DebugPlugin.getDefault.breakpointManager.getBreakpoints(debugModel)
	}
	
	def static addBreakpoint(IBreakpoint bp) { breakpointManager.addBreakpoint(bp) }
	def static getBreakpointManager() { DebugPlugin.getDefault.breakpointManager }
	
	def static isInLine(IBreakpoint bp, int line) { if (bp instanceof ILineBreakpoint) bp.lineNumber == line else false }
	
	def static refreshJob(ILaunchConfiguration configuration) {
		new Job("Refresh configurations") {
			override run(IProgressMonitor mon) {
				try
					RefreshTab.refreshResources(configuration, mon)
				//TODO: revisar manejo de exceptions
				catch (CoreException e)
					logger.error(e.message, e)
				catch (Throwable t)
					logger.error(t.message, t)
				Status.OK_STATUS
			}
		}
	}
	
	def static configType(String id) { launchManager.getLaunchConfigurationType(id) }
	def static launchManager() { DebugPlugin.getDefault.launchManager	}
	
	def static generateUniqueName(LaunchConfigurationInfo info) {
		launchManager.generateUniqueLaunchConfigurationNameFrom(info.name)
	}
	
	def static launch(ILaunchConfiguration conf, String mode) { 
		DebugUITools.launch(conf, mode)
	}
	
	def static fileURI(IBreakpoint bp) {
		bp.marker.resource.locationURI
	}
}