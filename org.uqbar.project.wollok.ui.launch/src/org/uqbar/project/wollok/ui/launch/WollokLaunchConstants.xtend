package org.uqbar.project.wollok.ui.launch

import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy

/**
 * 
 * @author jfernandes
 */
class WollokLaunchConstants {
	
	public static val WTEST_EXTENSIONS = "wtest"
	public static val EXTENSIONS = #["wlk", "wpgm", WTEST_EXTENSIONS]
	
	public static val LAUNCH_CONFIGURATION_TYPE = "org.uqbar.project.wollok.ui.launch.WollokLaunchConfigurationType"
	public static val ID_DEBUG_MODEL = "org.uqbar.project.wollok.debugger.model"
	
	public static final val LINE_BREAKPOINT_MARKER = "org.uqbar.project.wollok.ui.launch.lineBreakpoint.marker"
	
	// launch configurations custom attributes
	public static val ATTR_WOLLOK_FILE = "WOLLOK_FILE"
	public static val ATTR_WOLLOK_IS_REPL = "WOLLOK_IS_REPL"
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
	
	def static isWollokFileExtension(String xt) {
		xt != null && EXTENSIONS.contains(xt)
	}
	
}