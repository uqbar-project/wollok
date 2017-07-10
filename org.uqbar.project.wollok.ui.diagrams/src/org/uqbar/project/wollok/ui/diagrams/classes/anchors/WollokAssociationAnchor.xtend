package org.uqbar.project.wollok.ui.diagrams.classes.anchors

import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.geometry.Point
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

/**
 * 
 * Special anchor for associations. Connector goes from left to right
 * or from right to left depending on source/target positions.
 * 
 * Example when A knows B (left to right)
 * 
 *         _____________              ____________
 *        |      A      |----------> |      B     |
 *         -------------              ------------
 *
 * Example when B knows A (right to left)
 * 
 *         _____________             ____________
 *        |      A      |<----------|      B     |
 *         -------------             ------------
 * 
 * @author dodain
 * 
 */
class WollokAssociationAnchor extends DefaultWollokAnchor {

	Shape source
	Shape target
	
	new(IFigure owner, Connection connection) {
		super(owner)
		source = connection.source
		target = connection.target
	}
	
	override getReferencePoint() {
		if (source.location.isOnTheRightOf(target.location))
			owner.bounds.leftCenter.translateToAbsolute
		else
			owner.bounds.rightCenter.translateToAbsolute
	}
	
	override getLocation(Point reference) {
		if (source.location.isOnTheRightOf(target.location))
			owner.bounds.rightCenter.translateToAbsolute
		else
			owner.bounds.leftCenter.translateToAbsolute
	}
	
}
