package org.uqbar.project.wollok.debugger

import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.ILineBreakpoint
import org.eclipse.debug.core.model.IValue
import org.eclipse.debug.ui.IDebugModelPresentation
import org.eclipse.debug.ui.IValueDetailListener
import org.eclipse.jface.resource.JFaceResources
import org.eclipse.jface.resource.LocalResourceManager
import org.eclipse.jface.resource.ResourceManager
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.ui.IEditorInput
import org.eclipse.ui.part.FileEditorInput
import org.eclipse.ui.progress.UIJob
import org.uqbar.project.wollok.debugger.model.WollokVariable
import org.uqbar.project.wollok.ui.editor.WollokTextEditor
import org.uqbar.project.wollok.ui.launch.Activator

/**
 * 
 * @author jfernandes
 */
// TODO: esto está todo dummy
class WollokDebugModelPresentation extends LabelProvider implements IDebugModelPresentation {
	private ResourceManager resourceManager
	
	new() {
		new UIJob("Creating resource manager for debug model presentation") {
			override def runInUIThread(IProgressMonitor monitor) {
				resourceManager = new LocalResourceManager(JFaceResources.getResources());
				Status.OK_STATUS
			}
		}.schedule
	}

	override computeDetail(IValue value, IValueDetailListener listener) {
		var detail = try
			value.getValueString
		catch (DebugException e)
			""
		listener.detailComputed(value, detail)
	}

	override getImage(Object element) {
		if (element instanceof WollokVariable) {
			val imgName = element.icon
			if (imgName != null) {
				var imageDescriptor = Activator.getDefault.getImageDescriptor(imgName)
				getOrCreateResourceManager.createImage(imageDescriptor)
			} else
				super.getImage(element)
		} else
			super.getImage(element)
	}
	
	def synchronized getOrCreateResourceManager() {
		resourceManager
	}

	override def dispose() {
		super.dispose
		if (resourceManager != null)
			resourceManager.dispose
	}

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
