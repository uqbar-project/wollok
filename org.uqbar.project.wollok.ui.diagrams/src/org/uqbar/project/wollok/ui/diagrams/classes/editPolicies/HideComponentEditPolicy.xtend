package org.uqbar.project.wollok.ui.diagrams.classes.editPolicies

import org.eclipse.gef.editpolicies.ConnectionEditPolicy
import org.eclipse.gef.requests.GroupRequest
import org.uqbar.project.wollok.ui.diagrams.classes.model.commands.HideComponentCommand
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart

class HideComponentEditPolicy extends ConnectionEditPolicy {
	
	override protected getDeleteCommand(GroupRequest request) {
		val command = new HideComponentCommand => [
			component = host as AbstractMethodContainerEditPart
		]
		command
	}
	
}