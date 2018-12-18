package org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar

import java.util.Observable
import java.util.Observer
import org.eclipse.jface.action.Action
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.dynamic.DynamicDiagramView
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration

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

class RememberObjectPositionAction extends Action implements Observer {
	
	DynamicDiagramConfiguration configuration
	DynamicDiagramView diagram
	
	new(DynamicDiagramView diagram) {
		super(Messages.DynamicDiagram_RememberObjectPosition_Description, AS_CHECK_BOX)
		this.diagram = diagram
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/push-pin.png")	
		this.configuration = DynamicDiagramConfiguration.instance
		this.configuration.addObserver(this)
		this.checked = configuration.isRememberLocationsAndSizes
	}
	
	override run() {
		configuration.rememberLocationsAndSizes = !configuration.isRememberLocationsAndSizes
		configuration.initLocationsAndSizes  // just in case we don't want to remember anymore, cleaning up
		diagram.refreshView()
		this.update(null, DynamicDiagramConfiguration.CONFIGURATION_CHANGED)
	}
	
	override update(Observable o, Object event) {
		if (event !== null && event.equals(StaticDiagramConfiguration.CONFIGURATION_CHANGED)) {
			this.checked = configuration.isRememberLocationsAndSizes
		}
	}
	
}