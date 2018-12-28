package org.uqbar.project.wollok.ui.tests.shortcut

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.CoreException
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display
import org.uqbar.project.wollok.ui.launch.shortcut.LaunchConfigurationInfo
import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchShortcut
import org.uqbar.project.wollok.ui.tests.WollokTestResultView

import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages

/**
 * @author tesonep
 */
class WollokTestLaunchShortcut extends WollokLaunchShortcut {
	
	override createConfiguration(LaunchConfigurationInfo info) throws CoreException {
		val cfgType = LAUNCH_TEST_CONFIGURATION_TYPE.configType
		val runConfiguration = cfgType.newInstance(null, info.generateUniqueName)
		this.configureConfiguration(runConfiguration, info)
		runConfiguration.doSave
	}

	override launch(IFile currFile, String mode) {
		try {
			activateWollokTestResultView
			super.launch(currFile, mode)
		} catch (CoreException e) {
			MessageDialog.openError(Display.current.activeShell, WollokLaunchUIMessages.WollokTestLaunch_TITLE,
				WollokLaunchUIMessages.WollokTestLaunch_ERROR_MESSAGE)
		}
	}
	
	def void activateWollokTestResultView() {
		WollokTestResultView.activate()
	}

}
