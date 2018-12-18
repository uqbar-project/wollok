package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration

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
		val configuration = sourceContainer.configuration as StaticDiagramConfiguration
		return configuration !== null && configuration.canAddDependency(sourceContainer, targetContainer)
	}
	
	override execute() {
		(targetContainer.configuration as StaticDiagramConfiguration).addDependency(sourceContainer, targetContainer)
	}
	
}