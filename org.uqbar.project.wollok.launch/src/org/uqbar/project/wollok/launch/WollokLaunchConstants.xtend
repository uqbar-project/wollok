package org.uqbar.project.wollok.launch

import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy

/**
 * @author jfernandes
 */
class WollokLaunchConstants {
	
	public static val EXTENSION = "wlk"
	
	public static val LAUNCH_CONFIGURATION_TYPE = "org.uqbar.project.wollok.launch.WollokLaunchConfigurationType"
	public static val ID_DEBUG_MODEL = "org.uqbar.project.wollok.debugger.model"
	
	public static final val LINE_BREAKPOINT_MARKER = "org.uqbar.project.wollok.launch.lineBreakpoint.marker"
	
	// launch configurations custom attributes
	public static val ATTR_WOLLOK_FILE = "WOLLOK_FILE"
	public static val ATTR_WOLLOK_DEBUG_PARAM = "WOLLOK_DEBUG_PARAM"
	public static val ATTR_WOLLOK_DEBUG_COMMAND_PORT = "WOLLOK_DEBUG_COMMAND_PORT"
	public static val ATTR_WOLLOK_DEBUG_EVENT_PORT = "WOLLOK_DEBUG_EVENT_PORT"
	
	static def getCommandPort(ILaunchConfiguration config) {
		config.getAttribute(ATTR_WOLLOK_DEBUG_COMMAND_PORT, -1) // -1 ?
	}
	
	static def setCommandPort(ILaunchConfigurationWorkingCopy config, int port) {
		config.setAttribute(ATTR_WOLLOK_DEBUG_COMMAND_PORT, port)
	}
	
	static def getEventPort(ILaunchConfiguration config) {
		config.getAttribute(ATTR_WOLLOK_DEBUG_EVENT_PORT, -1) // -1 ?
	}
	
	static def setEventPort(ILaunchConfigurationWorkingCopy config, int port) {
		config.setAttribute(ATTR_WOLLOK_DEBUG_EVENT_PORT, port)
	}
	
	static def getWollokFile(ILaunchConfiguration config){
		config.getAttribute(ATTR_WOLLOK_FILE,"")
	}
}