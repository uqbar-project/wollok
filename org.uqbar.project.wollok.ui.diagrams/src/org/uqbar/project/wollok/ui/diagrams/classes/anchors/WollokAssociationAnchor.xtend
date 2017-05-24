package org.uqbar.project.wollok.ui.diagrams.classes.anchors

import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.geometry.Point
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

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
