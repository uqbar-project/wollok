package org.uqbar.project.wollok.ui.launch.handlers

import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.Platform
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy
import org.eclipse.debug.internal.ui.DebugUIMessages
import org.eclipse.debug.internal.ui.DebugUIPlugin
import org.eclipse.debug.ui.DebugUITools
import org.eclipse.debug.ui.RefreshTab
import org.eclipse.jdt.core.JavaCore
import org.uqbar.project.wollok.launch.WollokLauncher
import org.uqbar.project.wollok.ui.Messages

import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.*
import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*

class LaunchReplWithoutFileHandler extends AbstractHandler {
	override execute(ExecutionEvent event) throws ExecutionException {
		DebugUITools.launch(createConfiguration, "run");
		null
	}

	def createConfiguration() throws CoreException {
		val cfgType = LAUNCH_CONFIGURATION_TYPE.configType
		val x = cfgType.newInstance(null, "Wollok REPL")
		configureConfiguration(x)
		x.doSave
	}

	def configureConfiguration(ILaunchConfigurationWorkingCopy it) {
		val root =  ResourcesPlugin.getWorkspace().getRoot()
		val openProjects = root.projects.filter[ project | project.isOpen() && project.hasNature(JavaCore.NATURE_ID)]
		
		if(openProjects.empty){
			val x = new RuntimeException(Messages.LaunchReplWithoutFileHandler_notHavingWollokProject)
			DebugUIPlugin.errorDialog(DebugUIPlugin.shell, Messages.LaunchReplWithoutFileHandler_notHavingWollokProject, Messages.LaunchReplWithoutFileHandler_notHavingWollokProject, x) //
			throw x
		}
		
		setAttribute(ATTR_PROJECT_NAME, openProjects.get(0).name)
		setAttribute(ATTR_MAIN_TYPE_NAME, WollokLauncher.name)
		setAttribute(ATTR_STOP_IN_MAIN, false)
		setAttribute(ATTR_USE_START_ON_FIRST_THREAD, false) // fixes wollok-game in osx
		setAttribute(ATTR_PROGRAM_ARGUMENTS, "")
		setAttribute(ATTR_VM_ARGUMENTS, "-Duser.language=" + Platform.NL)
		setAttribute(ATTR_WOLLOK_FILE, "")
		setAttribute(ATTR_WOLLOK_IS_REPL, true)
		setAttribute(RefreshTab.ATTR_REFRESH_SCOPE, "${workspace}")
		setAttribute(RefreshTab.ATTR_REFRESH_RECURSIVE, true)
	}

}
