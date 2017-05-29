package org.uqbar.project.wollok.ui.launch.shortcut

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.debug.ui.ILaunchShortcut
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.IEditorPart

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Abstract base class for ILaunchShortcuts based on files.
 * Already adapts selection and editors to IFile.
 * 
 * Adding capability of running all tests of a project
 * 
 * @author jfernandes
 * @author dodain
 */
abstract class AbstractFileLaunchShortcut implements ILaunchShortcut {
	
	override launch(ISelection selection, String mode) {
		if (selection instanceof IStructuredSelection) {
			val object = selection.firstElement
			doLaunch(object, mode)
		}
	}

	override launch(IEditorPart editor, String mode) {
		launch(editor.editorInput.adapt(IFile), mode)
	}
	
	def void launch(IFile currFile, String mode)
	
	def void launch(IProject currProject, String mode) {
		throw new RuntimeException("Launcher not found for " + currProject)
	}
	
	def dispatch void doLaunch(IProject currProject, String mode) {
		launch(currProject, mode)
	}
	
	def dispatch void doLaunch(IPackageFragmentRoot packageRoot, String mode) {
		launch(packageRoot.javaProject.project, mode)
	}
	
	def dispatch void doLaunch(IAdaptable adaptable, String mode) {
		launch(adaptable.adapt(IFile), mode)		
	}
	
	def dispatch void doLaunch(Object o, String mode) {
		throw new RuntimeException("Launcher not found for " + o)
	}
}