package org.uqbar.project.wollok.ui.tests.shortcut

import java.util.List
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.jface.viewers.ISelection
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.part.ISetSelectionTarget
import org.uqbar.project.wollok.Messages

import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * 
 * A special launcher shortcut for running all tests in a project
 * 
 * @author dodain
 * 
 */
class WollokAllTestsLaunchShortcut extends WollokTestLaunchShortcut {
	
	override getOrCreateConfig(IFile currFile) {
		val config = super.getOrCreateConfig(currFile)
		val wc = config.getWorkingCopy
		wc.setAttribute(ATTR_WOLLOK_FILE, currFile.testFilesAsString)
		wc
	}
	
	/**
	 * If we are launching all tests in a project
	 * - first: check project has valid tests
	 * - then: take any test as a mock file and use default inherited configuration
	 * - before launching: remove file in configuration
	 * - finally: launch tests
	 */
	override launch(IProject currProject, String mode) {
		activateWollokTestResultView
		val List<IFile> testFiles = currProject.getTestFiles
		if (testFiles.empty) {
			MessageDialog.openError(Display.current.activeShell, Messages.TestLauncher_NoTestToRun_Title,
				Messages.TestLauncher_NoTestToRun_Message)
			return;
		}
		val currFile = testFiles.head
		this.doLaunch(currFile, mode)
	}

	override launch(IJavaProject currProject, String mode) {
		launch(currProject.elementName.project, mode)
	}
	
	def List<IFile> getTestFiles(IProject project) {
		project
			.allMembers
			.filter [ fileExtension !== null && fileExtension.equals(WTEST_EXTENSIONS) ]
			.toList
			.map [ adapt(IFile) ]
			.toList
	}
	
	def String testFilesAsString(IFile file) {
		file.project.testFiles.fold(new StringBuilder, [ sb, it  | sb.append(it.locationURI.toURL.file).append(" ") ]).toString
	}

}