package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import java.net.URL
import org.eclipse.jface.action.Action
import org.eclipse.jface.resource.ImageDescriptor
import org.uqbar.project.wollok.ui.diagrams.classes.ClassDiagramView
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration

class ShowVariablesToggleButton extends Action {
	StaticDiagramConfiguration configuration
	ClassDiagramView view

	new(String title, StaticDiagramConfiguration configuration, ClassDiagramView view) {
		super(title, AS_RADIO_BUTTON)
		this.configuration = configuration
		this.view = view
		this.checked = configuration.showVariables
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/wollok-icon-variable_16.png")
	}

	override run() {
		configuration.showVariables = !configuration.showVariables
		this.checked = configuration.showVariables
		view.refresh
	}

}

class RememberShapePositionsToggleButton extends Action {
	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title, AS_RADIO_BUTTON)
		this.configuration = configuration
		this.checked = configuration.rememberLocationAndSizeShapes
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.ui/icons/full/ovr16/pinned_ovr@2x.png"))
	}

	override run() {
		configuration.rememberLocationAndSizeShapes = !configuration.rememberLocationAndSizeShapes
		configuration.initLocationsAndSizes  // just in case we don't want to remember anymore, cleaning up
		this.checked = configuration.rememberLocationAndSizeShapes
	}
	
}

class CleanShapePositionsAction extends Action {
	StaticDiagramConfiguration configuration

	new(String title, StaticDiagramConfiguration configuration) {
		super(title)
		this.configuration = configuration
		imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.team.svn.ui/icons/wizards/find-clear.gif"))
	}

	override run() {
		configuration.initLocationsAndSizes
	}
	
}
