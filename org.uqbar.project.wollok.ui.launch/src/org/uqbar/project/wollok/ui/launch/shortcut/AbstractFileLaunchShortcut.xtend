package org.uqbar.project.wollok.ui.launch.shortcut

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.debug.ui.ILaunchShortcut
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.IEditorPart

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Abstract base class for ILaunchShortcuts based on files.
 * Already adapts selection and editors to IFile.
 * 
 * @author jfernandes
 */
abstract class AbstractFileLaunchShortcut implements ILaunchShortcut {
	
	override launch(ISelection selection, String mode) {
		if (selection instanceof IStructuredSelection) {
			val object = selection.firstElement
			if (object instanceof IAdaptable) {
				launch(object.adapt(IFile), mode)
			}
		}
	}

	override launch(IEditorPart editor, String mode) {
		launch(editor.editorInput.adapt(IFile), mode)
	}
	
	def void launch(IFile currFile, String mode)
	
}