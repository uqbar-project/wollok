package org.uqbar.project.wollok.ui.launch.shortcut

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.Platform
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy
import org.eclipse.debug.ui.RefreshTab
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.core.JavaModelException
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.launch.WollokLauncher
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants

import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.*
import static org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages.*
import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.LauncherExtensions.*
import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import static extension org.uqbar.project.wollok.ui.libraries.WollokLibrariesStore.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Launches a "run" or "debug" configuration (already existing or creates one)
 * for wollok.
 * 
 * Checks that WollokLaunch (the main() class) is in the current project's classpath.
 * 
 * @author jfernandes
 */
class WollokLaunchShortcut extends AbstractFileLaunchShortcut {

	override launch(IFile currFile, String mode) {
		if (currFile.project.hasErrors) {
			val confirm = MessageDialog.openQuestion(Display.current.activeShell,
				Messages.TestLauncher_CompilationErrorTitle, Messages.TestLauncher_SeeProblemTab)
			if(!confirm) return
		}
		doLaunch(currFile, mode)
	}

	def doLaunch(IFile currFile, String mode) {
		try {
			locateRunner(currFile)
			val config = getOrCreateConfig(currFile)
			config.activateDynamicDiagramIfNeeded(this.shouldActivateDynamicDiagram)
			config.launch(mode)
			currFile.refreshProject
		} catch (CoreException e)
			MessageDialog.openError(null, PROBLEM_LAUNCHING_WOLLOK, e.message)
	}

	def getOrCreateConfig(IFile currFile) {
		val info = new LaunchConfigurationInfo(currFile)
		val config = createConfiguration(info)
		val wc = config.getWorkingCopy
		configureConfiguration(wc, info)
		wc.doSave
		config.delete
		wc
	}

	def boolean shouldActivateDynamicDiagram() {
		// TODO: In a future step, we should also include programs
		this.hasRepl && WollokActivator.instance.preferenceStoreAccess.dynamicDiagramActivated
	}

	def locateRunner(IResource resource) throws CoreException {
		val project = JavaCore.create(resource.project)
		if (!isOnClasspath(WollokLauncher.name, project))
			throw new DebugException(
				Activator.PLUGIN_ID.errorStatus(ADD_LAUNCH_PLUGIN_DEPENDENCY + Activator.LAUNCHER_PLUGIN_ID))
	}

	def isOnClasspath(String fullyQualifiedName, IJavaProject project) {
		var f = fullyQualifiedName
		if (f.indexOf('$') != -1)
			f = f.replace('$', '.')
		try {
			val type = project.findType(fullyQualifiedName)
			type !== null && type.exists
		} catch (JavaModelException e) {
			false
		}
	}

	def hasRepl() { false }

	def createConfiguration(LaunchConfigurationInfo info) throws CoreException {
		val cfgType = LAUNCH_CONFIGURATION_TYPE.configType
		val configuration = cfgType.newInstance(null, info.generateUniqueName)
		configuration.doSave
	}

	def configureConfiguration(ILaunchConfigurationWorkingCopy it, LaunchConfigurationInfo info) {
		setAttribute(ATTR_PROJECT_NAME, info.project)
		setAttribute(ATTR_MAIN_TYPE_NAME, WollokLauncher.name)
		setAttribute(ATTR_STOP_IN_MAIN, false)
		setAttribute(ATTR_USE_START_ON_FIRST_THREAD, false) // fixes wollok-game in osx
		setAttribute(ATTR_PROGRAM_ARGUMENTS, info.file)
		setAttribute(ATTR_VM_ARGUMENTS, "-Duser.language=" + Platform.NL)
		setAttribute(ATTR_WOLLOK_FILE, info.file)
		setAttribute(RefreshTab.ATTR_REFRESH_SCOPE, "${workspace}")
		setAttribute(RefreshTab.ATTR_REFRESH_RECURSIVE, true)
		setAttribute(ATTR_WOLLOK_LIBS, newArrayList(info.findLibs))
		setAttribute(WollokLaunchConstants.ATTR_WOLLOK_IS_REPL, this.hasRepl)
		setAttribute(WollokLaunchConstants.ATTR_WOLLOK_DYNAMIC_DIAGRAM, this.shouldActivateDynamicDiagram)
		setAttribute(WollokLaunchConstants.ATTR_WOLLOK_DARK_MODE, environmentHasDarkTheme)
	}

	def static getWollokFile(ILaunch launch) {
		launch.launchConfiguration.getAttribute(ATTR_WOLLOK_FILE, null as String)
	}

	def static getWollokProject(ILaunch launch) {
		launch.launchConfiguration.getAttribute(ATTR_PROJECT_NAME, null as String)
	}

	def findLibs(LaunchConfigurationInfo info) {
		getProject(info.project).libPaths
	}

}

@Accessors
class LaunchConfigurationInfo {
	String name
	String project
	String file
	String folder // optional 
	boolean severalFiles
	Iterable<String> libs

	new(IFile file) {
		name = file.name
		project = file.project.name
		this.file = file.projectRelativePath.toString
		libs = getProject(project).libPaths.toList
	}

	def configEquals(ILaunchConfiguration a) throws CoreException {
		file.equalsIgnoreCase(a.getAttribute(ATTR_WOLLOK_FILE, "X"))
	}

	def sameFolder(String anotherFolder) {
		val folder1EmptyValue = this.folder.emptyValue
		val folder2EmptyValue = anotherFolder.emptyValue

		return (folder1EmptyValue && folder2EmptyValue) ||
			(!folder1EmptyValue && !folder2EmptyValue && this.folder.equalsIgnoreCase(anotherFolder)
		)
	}

	def emptyValue(String value) {
		value === null || value.trim.equals("")
	}

}
