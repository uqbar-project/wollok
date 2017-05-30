package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

class CreateDependencyCommand extends CreateAssociationCommand {

	override canExecute() {
		if (!super.canExecute()) return false
		val configuration = sourceContainer.configuration
		return configuration !== null && configuration.canAddDependency(sourceContainer, targetContainer)
	}
	
	override execute() {
		targetContainer.configuration.addDependency(sourceContainer, targetContainer)
	}
	
}