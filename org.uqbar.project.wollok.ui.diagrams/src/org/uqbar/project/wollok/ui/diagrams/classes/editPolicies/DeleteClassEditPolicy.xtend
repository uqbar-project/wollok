package org.uqbar.project.wollok.ui.diagrams.classes.editPolicies

import org.eclipse.gef.editpolicies.ComponentEditPolicy
import org.eclipse.gef.requests.GroupRequest
import org.uqbar.project.wollok.ui.diagrams.classes.model.commands.DeleteClassCommand
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart

class DeleteClassEditPolicy extends ComponentEditPolicy {
	
	override protected createDeleteCommand(GroupRequest deleteRequest) {
		println("Delete!!!")
		new DeleteClassCommand => [
			source = host as AbstractMethodContainerEditPart	
		]
	}
	
}
