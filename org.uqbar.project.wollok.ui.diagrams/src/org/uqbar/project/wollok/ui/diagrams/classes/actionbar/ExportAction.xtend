package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import org.eclipse.gef.GraphicalViewer
import org.eclipse.jface.action.Action
import org.eclipse.swt.SWT
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ImageSaveUtil.*

class ExportAction extends Action {
	
	@Accessors GraphicalViewer viewer
	
	new() {}
	
	new(GraphicalViewer _viewer) {
		viewer = _viewer
	}
	
	override run() {
		viewer.save("//home//fernando//Documents//classDiagram.jpg", SWT.IMAGE_JPEG)		
	}
	
}