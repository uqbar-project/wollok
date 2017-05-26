package org.uqbar.project.wollok.ui.diagrams.classes.editPolicies

import org.eclipse.draw2d.BendpointConnectionRouter
import org.eclipse.gef.editpolicies.GraphicalNodeEditPolicy
import org.eclipse.gef.requests.CreateConnectionRequest
import org.eclipse.gef.requests.ReconnectRequest
import org.uqbar.project.wollok.ui.diagrams.classes.model.commands.CreateAssociationCommand
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart

class CreateAssociationEditPolicy extends GraphicalNodeEditPolicy {
	
	override protected getConnectionCompleteCommand(CreateConnectionRequest request) {
		val command = request.startCommand as CreateAssociationCommand
		command.defineTarget(host as AbstractMethodContainerEditPart)
		command
	}
	
	override protected getConnectionCreateCommand(CreateConnectionRequest request) {
		new CreateAssociationCommand => [
			defineSource(host as AbstractMethodContainerEditPart)
			request.startCommand = it
		]
	}
	
	override protected getReconnectSourceCommand(ReconnectRequest request) {
		null
	}
	
	override protected getReconnectTargetCommand(ReconnectRequest request) {
		null
	}

	override protected getDummyConnectionRouter(CreateConnectionRequest request) {
		new BendpointConnectionRouter
	}

}
