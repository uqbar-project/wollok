package org.uqbar.project.wollok.ui.launch.handlers

import static extension org.uqbar.project.wollok.ui.libraries.WollokLibrariesStore.*
import com.google.inject.Inject
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.Platform
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy
import org.eclipse.debug.ui.DebugUITools
import org.eclipse.debug.ui.RefreshTab
import org.uqbar.project.wollok.launch.WollokLauncher
import org.uqbar.project.wollok.ui.wizard.WollokDslProjectInfo
import org.uqbar.project.wollok.ui.wizard.WollokProjectCreator

import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.*
import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*
import static org.uqbar.project.wollok.utils.WEclipseUtils.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*

/**
 * This launcher is used to launch the REPL without an open project.
 * What is actually doing is creating an empty project if there is no open, but it is hidden by the project view.
 * 
 * @author tesonep
 * 
 * @TODO: Check if there is a way of launching it calculating the complete classpath. 
 * This is not so easy as the classpath should include all the bundles used by the wollok launcher plugin and lib. 
 * So, the classpath should include all the plugins of XText and eclipse that we are using.
 * Calculating that path and launching the application is as heavy as creating the empty project. With the difference that the creation
 * of the empty project is only made once per workspace.
 * 
 */

class LaunchReplWithoutFileHandler extends AbstractHandler {
	@Inject WollokProjectCreator projectCreator

	public val String EMPTY_PROJECT_NAME = "__EMPTY__"

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
		val projects = openProjects
		var IProject projectToUse

		if (projects.empty) {
			projectToUse = getOrCreateEmptyProject()
		} else {
			projectToUse = projects.get(0)
		}

		setAttribute(ATTR_PROJECT_NAME, projectToUse.name)
		setAttribute(ATTR_MAIN_TYPE_NAME, WollokLauncher.name)
		setAttribute(ATTR_STOP_IN_MAIN, false)
		setAttribute(ATTR_USE_START_ON_FIRST_THREAD, false) // fixes wollok-game in osx
		setAttribute(ATTR_PROGRAM_ARGUMENTS, "")
		setAttribute(ATTR_VM_ARGUMENTS, "-Duser.language=" + Platform.NL)
		setAttribute(ATTR_WOLLOK_FILE, "")
		setAttribute(ATTR_WOLLOK_IS_REPL, true)
		setAttribute(RefreshTab.ATTR_REFRESH_SCOPE, "${workspace}")
		setAttribute(RefreshTab.ATTR_REFRESH_RECURSIVE, true)
		setAttribute(ATTR_WOLLOK_LIBS, newArrayList(projectToUse.libPaths))
	}

	def getOrCreateEmptyProject() {
		val emptyProject = getProject(EMPTY_PROJECT_NAME)

		if (emptyProject != null) {
			emptyProject.open(null)
			return emptyProject
		}

		projectCreator.projectInfo = new WollokDslProjectInfo() => [
			projectName = EMPTY_PROJECT_NAME
		]
		projectCreator.run(null)
		return getProject(EMPTY_PROJECT_NAME)
	}
}
