package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.eclipse.draw2d.Graphics

/**
 * 
 * Edit part for dependency relationships
 * 
 * @author dodain
 * 
 */
class DependencyConnectionEditPart extends AssociationConnectionEditPart {
	
	override createEdgeDecoration() {
		new AssociationPolygonDecoration => [
			lineStyle = Graphics.LINE_DASH
			opaque = false
		]
	}
	
}