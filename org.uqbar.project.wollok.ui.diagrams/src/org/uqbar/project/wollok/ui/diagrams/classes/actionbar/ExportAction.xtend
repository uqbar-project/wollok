package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import org.eclipse.gef.GraphicalViewer
import org.eclipse.jface.action.Action
import org.eclipse.swt.SWT
import org.eclipse.ui.PlatformUI
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ImageSaveUtil.*
import org.eclipse.swt.widgets.FileDialog

class ExportAction extends Action {
	
	@Accessors GraphicalViewer viewer
	
	new() {}
	
	new(GraphicalViewer _viewer) {
		viewer = _viewer
	}
	
	override run() {
		val shell = PlatformUI.workbench.activeWorkbenchWindow.shell
		val FileDialog fileSelecter = new FileDialog(shell, SWT.SAVE) => [
			filterExtensions = #[".png"]
			overwrite = true
		]
		val fileName = fileSelecter.open
		if (fileName != null && !fileName.equals("")) {
			viewer.save(fileName, SWT.IMAGE_PNG)		
		}
	}
	
}