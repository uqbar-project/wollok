package org.uqbar.project.wollok.ui.tests.shortcut

import java.util.List
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.CoreException
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages
import org.uqbar.project.wollok.ui.launch.shortcut.LaunchConfigurationInfo
import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchShortcut
import org.uqbar.project.wollok.ui.tests.WollokTestResultView

import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*

/**
 * @author tesonep
 */
class WollokTestLaunchShortcut extends WollokLaunchShortcut {
	
	List<IFile> files = newArrayList

	override init() {
		this.files = newArrayList
	}

	override createConfiguration(LaunchConfigurationInfo info) throws CoreException {
		val cfgType = LAUNCH_TEST_CONFIGURATION_TYPE.configType
		val runConfiguration = cfgType.newInstance(null, info.generateUniqueName)
		this.configureConfiguration(runConfiguration, info)
		runConfiguration.doSave
	}

	override configureConfiguration(ILaunchConfigurationWorkingCopy it, LaunchConfigurationInfo info) {
		super.configureConfiguration(it, info)
		if (!this.files.isEmpty) {
			setAttribute(ATTR_WOLLOK_FILE, this.files.testFiles)
			setAttribute(ATTR_WOLLOK_SEVERAL_FILES, true)
		}
	}

	override launch(IFile currFile, String mode) {
		try {
			super.launch(currFile, mode)
		} catch (CoreException e) {
			MessageDialog.openError(Display.current.activeShell, WollokLaunchUIMessages.WollokTestLaunch_TITLE,
				WollokLaunchUIMessages.WollokTestLaunch_ERROR_MESSAGE)
		}
	}
	
	override launch(List<IFile> files, String mode) {
		this.files = files
		this.files.internalLaunch(mode)
	}	

	def internalLaunch(List<IFile> testFiles, String mode) {
		if (testFiles.empty) {
			MessageDialog.openError(Display.current.activeShell, Messages.TestLauncher_NoTestToRun_Title,
				Messages.TestLauncher_NoTestToRun_Message)
			return;
		}
		val currFile = testFiles.head
		this.doLaunch(currFile, mode)
	}

	override doLaunch(IFile currFile, String mode) {
		activateWollokTestResultView
		super.doLaunch(currFile, mode)
	}

	override shouldActivateDynamicDiagram() {
		false
	}	

	def void activateWollokTestResultView() {
		WollokTestResultView.activate()
	}

	def String testFiles(List<IFile> files) {
		files.fold(new StringBuilder, [ sb, testFile |
			val filePath = testFile.projectRelativePath.toString
			sb.append(filePath).append(" ")
		]).toString
	}

}

class WollokTestDynamicDiagramLaunchShortcut extends WollokTestLaunchShortcut {

	override shouldActivateDynamicDiagram() {
		true
	}	

}