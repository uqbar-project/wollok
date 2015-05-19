package org.uqbar.project.wollok.debugger

import org.eclipse.core.runtime.CoreException
import org.eclipse.debug.ui.actions.IToggleBreakpointsTarget
import org.eclipse.jface.text.ITextSelection
import org.eclipse.jface.viewers.ISelection
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.texteditor.ITextEditor
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants
import org.uqbar.project.wollok.debugger.model.WollokLineBreakpoint

import static org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Adapts an ITextEditor and selection to ITogglebreakpointsTarget.
 * So that you can add breakpoints to your xtext editor.
 * 
 * @author jfernandes
 */
class WollokLineBreakpointAdapter implements IToggleBreakpointsTarget {
	
	override toggleLineBreakpoints(IWorkbenchPart part, ISelection selection) throws CoreException {
		val textEditor = part.editor
		if (textEditor != null) {
			val resource = textEditor.resource
			val lineNumber = (selection as ITextSelection).startLine
		
			val alreadyABp = ID_DEBUG_MODEL.breakpoints.findFirst[marker.resource == resource && isInLine(lineNumber + 1)]
			if (alreadyABp != null) 
				alreadyABp.delete
			else 
				new WollokLineBreakpoint(resource, lineNumber + 1).addBreakpoint
		}
	}
	
	def getEditor(IWorkbenchPart part) {
		if (part instanceof ITextEditor) {
			val resource = part.resource
			if (resource != null) {
				val ext = resource.getFileExtension
				if (WollokLaunchConstants.isWollokFileExtension(ext))
					return part
			}
		}
		return null
	}
	
	override canToggleLineBreakpoints(IWorkbenchPart part, ISelection selection) {
		part.editor != null
	}
	
	// *************************************
	// ** unimplemented !
	// *************************************
	
	override canToggleMethodBreakpoints(IWorkbenchPart part, ISelection selection) { false }
	override toggleMethodBreakpoints(IWorkbenchPart part, ISelection selection) throws CoreException {}
	
	override canToggleWatchpoints(IWorkbenchPart part, ISelection selection) { false }
	override toggleWatchpoints(IWorkbenchPart part, ISelection selection) throws CoreException {}
	
}