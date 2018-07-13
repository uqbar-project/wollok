package org.uqbar.project.wollok.ui.launch.shortcut

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.debug.ui.ILaunchShortcut
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.osgi.util.NLS
import org.eclipse.ui.IEditorPart
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages

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
		currProject.throwLauncherNotFound
	}
	
	def void launch(IJavaProject currProject, String mode) {
		currProject.throwLauncherNotFound
	}
	
	def void launch(IFolder currFolder, String mode) {
		currFolder.throwLauncherNotFound
	}
	
	def void throwLauncherNotFound(Object o) {
		throw new RuntimeException(NLS.bind(WollokLaunchUIMessages.WollokLaunch_GENERAL_ERROR_MESSAGE, o.toString))
	}

	def dispatch void doLaunch(IProject currProject, String mode) {
		launch(currProject, mode)
	}
	
	def dispatch void doLaunch(IPackageFragmentRoot packageRoot, String mode) {
		launch(packageRoot.javaProject.project, mode)
	}
	
	def dispatch void doLaunch(IJavaProject project, String mode) {
		launch(project, mode)	
	}
	
	def dispatch void doLaunch(IPackageFragment _package, String mode) {
		launch(_package.correspondingResource.adapt(IFolder), mode)
	}
	
	def dispatch void doLaunch(IAdaptable adaptable, String mode) {
		launch(adaptable.adapt(IFile), mode)
	}
	
	def dispatch void doLaunch(Object o, String mode) {
		o.throwLauncherNotFound
	}
}