package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import org.eclipse.draw2d.PolygonDecoration
import org.eclipse.draw2d.PolylineConnection
import org.eclipse.draw2d.XYAnchor
import org.eclipse.draw2d.geometry.Point
import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart
import org.uqbar.project.wollok.ui.diagrams.editparts.ReferenceLocator

/**
 * 
 * @author jfernandes
 * @author dodain          Adding a custom connection locator for references
 */
class ReferenceConnectionEditPart extends ConnectionEditPart {
	
	override createEdgeDecoration() {
		new PolygonDecoration
	}
	
	override createConnectionLocator(PolylineConnection connection) {
		new ReferenceLocator(connection)
	}
	
	override getSourceConnectionAnchor() {
		if (source !== null || !(this.target instanceof ValueEditPart)) 
			return super.sourceConnectionAnchor
		val object = (this.target as ValueEditPart).castedModel
		var y = object.YValueForAnchor
		try {
			val targetVariables = object.targetConnections.map [ conn | conn.name ]
			val index = targetVariables.indexOf(this.castedModel.name)
			y = y + index * 27
		} catch (Exception e) {
			// Nothing, maybe algorithm is too complicated
		}
		new XYAnchor(new Point(10, y))
	}
	
}
