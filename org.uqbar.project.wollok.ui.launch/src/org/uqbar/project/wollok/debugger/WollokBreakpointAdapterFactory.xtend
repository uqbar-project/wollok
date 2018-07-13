package org.uqbar.project.wollok.debugger

import org.eclipse.core.runtime.IAdapterFactory
import org.eclipse.debug.ui.actions.IToggleBreakpointsTarget
import org.eclipse.ui.texteditor.ITextEditor
import org.eclipse.xtext.ui.editor.XtextEditor
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * 
 * @author jfernandes
 */
class WollokBreakpointAdapterFactory implements IAdapterFactory {

	override getAdapter(Object adaptableObject, Class adapterType) {
		if (adaptableObject instanceof XtextEditor) {
			val editorPart = adaptableObject as ITextEditor
			val resource = editorPart.resource
			if (resource !== null) {
				val xt = resource.fileExtension
				
				if (WollokLaunchConstants.isWollokFileExtension(xt)) {
					return new WollokLineBreakpointAdapter
				}
			}			
		}
		return null;
	}
	
	override getAdapterList() {
		#[IToggleBreakpointsTarget]
	}
	
}