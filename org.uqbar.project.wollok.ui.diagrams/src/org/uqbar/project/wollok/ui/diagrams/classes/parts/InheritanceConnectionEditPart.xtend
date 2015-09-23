package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.eclipse.draw2d.ColorConstants
import org.eclipse.draw2d.PolygonDecoration
import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart

/**
 * @author jfernandes
 */
class InheritanceConnectionEditPart extends ConnectionEditPart {
	
	override createEdgeDecoration() {
		new PolygonDecoration => [
			backgroundColor = ColorConstants.white
		]
	}
	
}