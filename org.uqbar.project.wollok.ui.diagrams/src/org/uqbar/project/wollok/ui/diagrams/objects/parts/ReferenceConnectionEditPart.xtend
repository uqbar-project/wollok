package org.uqbar.project.wollok.ui.diagrams.objects.parts

import org.eclipse.draw2d.PolygonDecoration
import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart

/**
 * 
 * @author jfernandes
 */
class ReferenceConnectionEditPart extends ConnectionEditPart {
	
	override createEdgeDecoration() {
		new PolygonDecoration
	}
	
}