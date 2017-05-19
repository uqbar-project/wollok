package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

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
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/wollok-icon-variable_16.png")
	}

	override run() {
		configuration.showVariables = !configuration.showVariables
		this.checked = configuration.showVariables
		view.refresh
	}

}
