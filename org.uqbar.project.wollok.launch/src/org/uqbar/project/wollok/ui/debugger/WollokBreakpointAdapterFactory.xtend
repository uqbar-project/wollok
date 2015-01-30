package org.uqbar.project.wollok.ui.debugger

import org.eclipse.core.runtime.IAdapterFactory
import org.eclipse.ui.texteditor.ITextEditor

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import org.uqbar.project.wollok.launch.WollokLaunchConstants
import org.eclipse.debug.ui.actions.IToggleBreakpointsTarget
import org.eclipse.xtext.ui.editor.XtextEditor

/**
 * 
 * @author jfernandes
 */
class WollokBreakpointAdapterFactory implements IAdapterFactory {
	
	override getAdapter(Object adaptableObject, Class adapterType) {
		if (adaptableObject instanceof XtextEditor) {
			val editorPart = adaptableObject as ITextEditor
			val resource = editorPart.resource
			if (resource != null) {
				val xt = resource.fileExtension
				if (xt != null && xt.equals(WollokLaunchConstants.EXTENSION)) {
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