package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

class CreateDependencyCommand extends CreateAssociationCommand {

	override execute() {
		targetContainer.configuration.addDependency(sourceContainer, targetContainer)
	}
	
}