package org.uqbar.project.wollok.ui.diagrams.classes.model.commands

import org.eclipse.gef.commands.Command
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart

@Accessors
class CreateAssociationCommand extends Command {
	AbstractModel sourceContainer
	AbstractModel targetContainer
	
	override canExecute() {
		sourceContainer !== null && targetContainer !== null
	}
	
	override execute() {
		targetContainer.configuration.addAssociation(sourceContainer, targetContainer)
	}
	
	def defineSource(AbstractMethodContainerEditPart part) {
		sourceContainer = part.castedModel as AbstractModel
	}
	
	def defineTarget(AbstractMethodContainerEditPart part) {
		targetContainer = part.castedModel as AbstractModel
	}
	
}
