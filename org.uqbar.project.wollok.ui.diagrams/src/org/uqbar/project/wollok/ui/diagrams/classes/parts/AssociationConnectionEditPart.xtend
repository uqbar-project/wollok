package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.eclipse.gef.EditPolicy
import org.eclipse.gef.editpolicies.NonResizableEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.editPolicies.DeleteConnectionEditPolicy
import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart

public class AssociationConnectionEditPart extends ConnectionEditPart {

	new() {
		super()
	}

	override createEdgeDecoration() {
		new AssociationPolygonDecoration
	}
	
	override createEditPolicies() {
		// in order to be selectable
		installEditPolicy(EditPolicy.PRIMARY_DRAG_ROLE, new NonResizableEditPolicy)
    	installEditPolicy(EditPolicy.CONNECTION_ROLE, new DeleteConnectionEditPolicy)
	}
	
}
