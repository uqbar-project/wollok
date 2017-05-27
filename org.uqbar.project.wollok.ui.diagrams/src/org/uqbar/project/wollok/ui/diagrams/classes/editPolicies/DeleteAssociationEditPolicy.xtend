package org.uqbar.project.wollok.ui.diagrams.classes.editPolicies

import org.eclipse.gef.editpolicies.ConnectionEditPolicy
import org.eclipse.gef.requests.GroupRequest
import org.uqbar.project.wollok.ui.diagrams.classes.model.commands.DeleteAssociationCommand
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart

class DeleteAssociationEditPolicy extends ConnectionEditPolicy {
	
	override protected getDeleteCommand(GroupRequest request) {
		val command = new DeleteAssociationCommand => [
			connection = host as AssociationConnectionEditPart
		]
		command
	}
	
}