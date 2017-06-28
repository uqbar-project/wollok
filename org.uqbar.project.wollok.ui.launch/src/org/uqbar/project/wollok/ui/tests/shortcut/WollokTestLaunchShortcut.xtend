package org.uqbar.project.wollok.ui.tests.shortcut

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.CoreException
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.PlatformUI
import org.uqbar.project.wollok.Messages
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

	override doLaunch(IFile currFile, String mode) {
		try {
			activateWollokTestResultView
			super.doLaunch(currFile, mode)
		} catch (CoreException e) {
			// TODO: i18n
			MessageDialog.openError(Display.current.activeShell, Messages.TestLauncher_LauncherError_Title,
				Messages.TestLauncher_LauncherError_Message)
			// something went wrong
		}
	}
	
	def activateWollokTestResultView() {
		RunInUI.runInUI [
				PlatformUI.workbench.activeWorkbenchWindow.activePage.showView(WollokTestResultView.NAME)
			]
	}

}
