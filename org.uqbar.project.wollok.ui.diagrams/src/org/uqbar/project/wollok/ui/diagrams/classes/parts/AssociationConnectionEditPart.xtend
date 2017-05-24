package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart

public class AssociationConnectionEditPart extends ConnectionEditPart {

	new() {
		super()
	}

	override createEdgeDecoration() {
		new AssociationPolygonDecoration
	}

}
