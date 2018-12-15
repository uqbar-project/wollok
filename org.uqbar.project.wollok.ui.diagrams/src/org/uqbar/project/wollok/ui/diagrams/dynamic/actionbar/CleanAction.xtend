package org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar

import org.eclipse.gef.GraphicalViewer
import org.eclipse.jface.action.Action
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.dynamic.DynamicDiagramView

/**
 * Clean dynamic diagram
 */ 
class CleanAction extends Action {
	
	@Accessors DynamicDiagramView diagram
	
	new() {
		init
	}
	
	def void init() {
		toolTipText = Messages.DynamicDiagram_Clean_Description
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/eraser.png")	
	}
	
	override run() {
		diagram.cleanDiagram()
	}
	
}