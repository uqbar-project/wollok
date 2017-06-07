package org.uqbar.project.wollok.ui.diagrams.classes.editPolicies

import org.eclipse.gef.editpolicies.ConnectionEditPolicy
import org.eclipse.gef.requests.GroupRequest
import org.uqbar.project.wollok.ui.diagrams.classes.model.commands.DeleteConnectionCommand
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart

/**
 * 
 * Feedback effect that allows user to delete a connection, basically
 * association and dependency relationships
 *  
 */
class DeleteConnectionEditPolicy extends ConnectionEditPolicy {
	
	override protected getDeleteCommand(GroupRequest request) {
		val command = new DeleteConnectionCommand => [
			connection = host as AssociationConnectionEditPart
		]
		command
	}
	
}