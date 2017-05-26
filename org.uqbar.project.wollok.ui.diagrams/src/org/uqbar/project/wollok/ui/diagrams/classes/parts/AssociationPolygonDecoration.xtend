package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.eclipse.draw2d.Connection
import org.eclipse.draw2d.ConnectionAnchor
import org.eclipse.draw2d.ConnectionRouter
import org.eclipse.draw2d.FanRouter
import org.eclipse.draw2d.PolylineDecoration

/**
 * 
 * Decoration for associations, so you can see
 * O-->O
 * 
 * @author dodain
 * 
 * Thanks to
 * https://www.vainolo.com/2011/08/03/creating-an-opm-gef-editor-part-13-adding-procedural-links/
 * 
 */
class AssociationPolygonDecoration extends PolylineDecoration {
	
	new() {
		fill = true
		opaque = true
	}
	
}