package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

/**
 * 
 * Create Dependency Command allows to create a new dependency relationship
 * between 2 containers if 
 * - both are selected
 * - and if configuration allows to do so 
 * 
 * @author dodain
 * 
 */
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