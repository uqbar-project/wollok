package org.uqbar.project.wollok.ui.diagrams.classes.editPolicies

import org.eclipse.gef.editpolicies.ConnectionEditPolicy
import org.eclipse.gef.requests.GroupRequest
import org.uqbar.project.wollok.ui.diagrams.classes.model.commands.ShowHiddenPartsElementCommand

class ShowHiddenPartsElementEditPolicy extends ConnectionEditPolicy {
	
	override protected getDeleteCommand(GroupRequest request) {
		new ShowHiddenPartsElementCommand
	}
	
}