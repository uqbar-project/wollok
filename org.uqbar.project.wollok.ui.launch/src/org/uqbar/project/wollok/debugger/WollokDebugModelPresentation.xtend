package org.uqbar.project.wollok.debugger

import org.eclipse.core.resources.IFile
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.ILineBreakpoint
import org.eclipse.debug.core.model.IValue
import org.eclipse.debug.ui.IDebugModelPresentation
import org.eclipse.debug.ui.IValueDetailListener
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.ui.IEditorInput
import org.eclipse.ui.part.FileEditorInput
import org.uqbar.project.wollok.debugger.model.WollokVariable
import org.uqbar.project.wollok.ui.editor.WollokTextEditor
import org.uqbar.project.wollok.ui.launch.Activator

/**
 * 
 * @author jfernandes
 */
 //TODO: esto está todo dummy
class WollokDebugModelPresentation extends LabelProvider implements IDebugModelPresentation {
	
	override computeDetail(IValue value, IValueDetailListener listener) {
		var detail = try value.getValueString catch (DebugException e) ""
		listener.detailComputed(value, detail)
	}
	
	override getImage(Object element) {
		if (element instanceof WollokVariable) {
			val imgName = element.icon
			if (imgName != null)
				Activator.getDefault.getImageDescriptor(imgName).createImage
			else
				super.getImage(element)	
		}
		else
			super.getImage(element)
	}
	
//	override getImage(Object element) { null }
//	override getText(Object element) { null }
	
	override setAttribute(String attribute, Object value) {}
	
	override getEditorId(IEditorInput input, Object element) {
		if (element instanceof IFile || element instanceof ILineBreakpoint)
			WollokTextEditor.ID
		else
			null
	}
	
	override getEditorInput(Object element) {
		if (element instanceof IFile)
			new FileEditorInput(element)
		else if (element instanceof ILineBreakpoint)
			new FileEditorInput(element.marker.resource as IFile)
		else 
			null
	}
	
}