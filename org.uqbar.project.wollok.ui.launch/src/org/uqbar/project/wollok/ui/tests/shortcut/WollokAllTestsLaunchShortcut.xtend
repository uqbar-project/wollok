package org.uqbar.project.wollok.ui.tests.shortcut

import java.util.List
import java.util.Set
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display
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
	
	IFolder folder
	
	override getOrCreateConfig(IFile currFile) {
		val config = super.getOrCreateConfig(currFile)
		val runConfiguration = config.getWorkingCopy
		runConfiguration.setAttribute(ATTR_WOLLOK_FILE, currFile.testFilesAsString)
		runConfiguration
	}
	
	/**
	 * If we are launching all tests in a project
	 * - first: check project has valid tests
	 * - then: take any test as a mock file and use default inherited configuration
	 * - before launching: remove file in configuration
	 * - finally: launch tests
	 */
	override launch(IProject currProject, String mode) {
		this.folder = null
		currProject.getTestFiles.internalLaunch(mode)
	}

	override launch(IFolder folder, String mode) {
		this.folder = folder
		folder.getTestFiles.internalLaunch(mode)
	}

	def internalLaunch(List<IFile> testFiles, String mode) {
		activateWollokTestResultView
		if (testFiles.empty) {
			MessageDialog.openError(Display.current.activeShell, Messages.TestLauncher_NoTestToRun_Title,
				Messages.TestLauncher_NoTestToRun_Message)
			return;
		}
		val currFile = testFiles.head
		this.doLaunch(currFile, mode)
	}
	
	override launch(IJavaProject currProject, String mode) {
		this.folder = null
		launch(currProject.elementName.project, mode)
	}
	
	def List<IFile> getTestFiles(IProject project) {
		project.allMembers.testFiles
	}

	def List<IFile> getTestFiles(IFolder folder) {
		folder.allMembers.testFiles
	}
	
	def List<IFile> getTestFiles(Set<IResource> files) {
		files
			.filter [
				fileExtension !== null && fileExtension.equals(WTEST_EXTENSIONS)
			]
			.toList
			.map [ adapt(IFile) ]
			.toList
	}
	
	def String testFilesAsString(IFile file) {
		var testFiles = file.project.testFiles
		if (this.folder !== null) {
			testFiles = folder.testFiles
		}
		testFiles.fold(new StringBuilder, [ sb, testFile |
			val filePath = testFile.projectRelativePath.toString
			sb.append(filePath).append(" ")
		]).toString
	}

}