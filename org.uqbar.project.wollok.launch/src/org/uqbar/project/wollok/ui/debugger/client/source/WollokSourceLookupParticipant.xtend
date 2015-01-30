package org.uqbar.project.wollok.ui.debugger.client.source

import org.eclipse.core.runtime.CoreException
import org.eclipse.debug.core.sourcelookup.AbstractSourceLookupParticipant
import org.uqbar.project.wollok.ui.debugger.model.WollokStackFrame

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Given a stack frame it resolves the file to be opened by the editor.
 * 
 * As the interpreter sends us the full path to the file, we don't need to do much
 * We just ask eclipse for a IFile object given that full path.
 * 
 * Superclass is actually not needed.
 * 
 * Of course this only works for wollok files.
 * 
 * @author jfernandes
 */
// I'm not user if this is going to work for cross-project files references. 
class WollokSourceLookupParticipant extends AbstractSourceLookupParticipant {
	override getSourceName(Object object) throws CoreException {
		if (object instanceof WollokStackFrame)
			(object as WollokStackFrame).sourceName
		else 
			null
	}
	
	override findSourceElements(Object object) throws CoreException {
		if (object instanceof WollokStackFrame) {
			#[object.fileURI.toIFile]
		}
		else
			super.findSourceElements(object)
	}
	
}