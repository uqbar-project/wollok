package org.uqbar.project.wollok.ui.diagrams.classes.anchors

import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.geometry.Point

/**
 * 
 * Anchor for self references (just association relationships).
 * Current implementation uses bottom right corner to avoid collisions with other
 * inheritance and association connectors, like this
 * 
 *         _____________   
 *        |      x      |      x is where inheritance location goes  
 *         -------------   
 *                 |   ^
 *                 |   |
 *                 -----
 * 
 * 
 * @author dodain
 * 
 */
class SelfReferenceAnchor extends DefaultWollokAnchor {
	
	public static int DELTA = 5
	
	new(IFigure owner) {
		super(owner)
	}
	
	override getReferencePoint() {
		val point = owner.bounds.bottomRight.translateToAbsolute
		new Point(point.x - (DELTA * 5), point.y)
	}
	
	override getLocation(Point reference) {
		val point = owner.bounds.bottomRight.translateToAbsolute
		new Point(point.x - DELTA, point.y)
	}
	
}

class SelfReferenceConnectionAnchor extends DefaultWollokAnchor {
	
	public static int DELTA = 5
	
	new(IFigure owner) {
		super(owner)
	}
	
	override getReferencePoint() {
		val point = owner.bounds.bottomLeft.translateToAbsolute
		new Point(point.x, point.y + (DELTA * 3))
	}
	
	override getLocation(Point reference) {
		val point = owner.bounds.bottomRight.translateToAbsolute
		new Point(point.x, point.y - (DELTA * 3))
	}
	
}
