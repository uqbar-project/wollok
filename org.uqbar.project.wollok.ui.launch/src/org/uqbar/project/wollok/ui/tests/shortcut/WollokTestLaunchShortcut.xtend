package org.uqbar.project.wollok.ui.tests.shortcut

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.CoreException
import org.eclipse.ui.PlatformUI
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.launch.shortcut.LaunchConfigurationInfo
import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchShortcut
import org.uqbar.project.wollok.ui.tests.WollokTestResultView

import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*

/**
 * @author tesonep
 */
class WollokTestLaunchShortcut extends WollokLaunchShortcut {
	override createConfiguration(LaunchConfigurationInfo info) throws CoreException {
		val cfgType = LAUNCH_TEST_CONFIGURATION_TYPE.configType
		val x = cfgType.newInstance(null, info.generateUniqueName)
		this.configureConfiguration(x, info)
		x.doSave
	}
	
	override launch(IFile currFile, String mode) {
		RunInUI.runInUI[ 
			PlatformUI.workbench.activeWorkbenchWindow.activePage.showView(WollokTestResultView.NAME)
		]
		super.launch(currFile, mode)
	}

}
