package org.uqbar.project.wollok.ui.launch.shortcut

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.CoreException
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.DebugPlugin
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.ILaunchManager
import org.eclipse.debug.ui.IDebugUIConstants
import org.eclipse.debug.ui.RefreshTab
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.core.JavaModelException
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.xtend.lib.Property
import org.uqbar.project.wollok.launch.WollokLauncher
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants

import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.*
import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import org.eclipse.debug.internal.ui.DebugUIPlugin

/**
 * Launches a "run" or "debug" configuration (already existing or creates one)
 * for wollok.
 * 
 * Checks that WollokLaunch (the main() class) is in the current project's classpath.
 * 
 * @author jfernandes
 */
class WollokLaunchShortcut extends AbstractFileLaunchShortcut {
	ILaunchManager launchManager = DebugPlugin.getDefault.launchManager
	
	override launch(IFile currFile, String mode) {
		try {
			locateRunner(currFile)
			getOrCreateConfig(currFile).launch(mode)
			currFile.refreshProject
		}
		catch (CoreException e)
			MessageDialog.openError(null, "Problem running launcher.", e.message)
	}
	
	def getOrCreateConfig(IFile currFile) {
		val info = new LaunchConfigurationInfo(currFile)
		val config = launchManager.launchConfigurations.findFirstIfNone([
			info.configEquals(it)
		], [| 
			createConfiguration(info)
		])
		val wc = config.getWorkingCopy
		wc.setAttribute(WollokLaunchConstants.ATTR_WOLLOK_IS_REPL, this.hasRepl)
		// It returns the modified launch config
		wc.doSave
	}
	
	def locateRunner(IResource resource) throws CoreException {
		val project = JavaCore.create(resource.project)
		if (!isOnClasspath(WollokLauncher.name, project))
			throw new DebugException(Activator.PLUGIN_ID.errorStatus("Please put bundle '" + Activator.PLUGIN_ID + "' on your project's classpath."))
	}

	def isOnClasspath(String fullyQualifiedName, IJavaProject project) {
		var f = fullyQualifiedName
		if (f.indexOf('$') != -1)
			f = f.replace('$', '.');
		try {
			val type = project.findType(fullyQualifiedName);
			type != null && type.exists
		} catch (JavaModelException e) {
			false
		}
	}

	def hasRepl(){false}

	def createConfiguration(LaunchConfigurationInfo info) throws CoreException {
		val cfgType = LAUNCH_CONFIGURATION_TYPE.configType
		val x = cfgType.newInstance(null, info.generateUniqueName)
		x => [
			setAttribute(ATTR_PROJECT_NAME, info.project)
			setAttribute(ATTR_MAIN_TYPE_NAME, WollokLauncher.name)
			setAttribute(ATTR_STOP_IN_MAIN, false)
			setAttribute(ATTR_PROGRAM_ARGUMENTS, info.file)
			setAttribute(ATTR_WOLLOK_FILE, info.file)
			setAttribute(ATTR_WOLLOK_IS_REPL, this.hasRepl)
			setAttribute(RefreshTab.ATTR_REFRESH_SCOPE, "${workspace}")
			setAttribute(RefreshTab.ATTR_REFRESH_RECURSIVE, true)
		]
		x.doSave
	}
}

class LaunchConfigurationInfo {
	@Property String name;
	@Property String project;
	@Property String file;

	new(IFile file) {
		name = file.name
		project = file.project.name
		this.file = file.projectRelativePath.toString
	}

	def configEquals(ILaunchConfiguration a) throws CoreException {
		file == a.getAttribute(ATTR_WOLLOK_FILE, "X")
			&& WollokLauncher.name == a.getAttribute(ATTR_MAIN_TYPE_NAME, "X")
			&& project == a.getAttribute(ATTR_PROJECT_NAME, "X")
			&& LAUNCH_CONFIGURATION_TYPE == a.type.identifier
	}
}