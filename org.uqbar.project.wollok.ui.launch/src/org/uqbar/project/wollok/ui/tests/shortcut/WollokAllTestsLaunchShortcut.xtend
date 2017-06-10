package org.uqbar.project.wollok.ui.tests.shortcut

import java.util.List
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display

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
		if (!checkEclipseProject(currProject)) return;
		activateWollokTestResultView
		val List<IFile> testFiles = currProject.getTestFiles
		if (testFiles.empty) {
			// TODO: i18n
			MessageDialog.openError(Display.current.activeShell, "No tests to run",
				"There are no tests to run")
			return;
		} 
		val currFile = testFiles.head
		this.launch(currFile, mode)
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