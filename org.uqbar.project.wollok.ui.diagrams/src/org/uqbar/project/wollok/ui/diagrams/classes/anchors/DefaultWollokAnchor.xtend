package org.uqbar.project.wollok.ui.diagrams.classes.anchors

import org.eclipse.draw2d.ChopboxAnchor
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.geometry.Point
import org.eclipse.draw2d.geometry.Rectangle

/**
 * 
 * Default implementation for connections between shapes, assuming 
 * inheritance was the first automatic relationship we could infer from classes.
 * 
 * @author dodain
 * 
 */
class DefaultWollokAnchor extends ChopboxAnchor {
	
	new() {
		super()
	}
	
	new(IFigure owner) {
		super(owner)	
	}
	
	def translateToAbsolute(Point point) {
		val newPoint = point
		owner.translateToAbsolute(newPoint)
		newPoint	
	}
	
	def translateToRelative(Rectangle rectangle) {
		val newRectangle = rectangle
		owner.translateToRelative(newRectangle)
		newRectangle
	}

	
	override getReferencePoint() {
		owner.bounds.middleTop.translateToAbsolute
	}
	
	override getLocation(Point reference) {
		owner.bounds.middleBottom.translateToAbsolute
	}
	
	def static getRightCenter(Rectangle it) { new Point(x + width, y + height / 2) }
	def static getMiddleTop(Rectangle it) { new Point(x + width / 2, y) }
	def static getLeftCenter(Rectangle it) { new Point(x, y + height / 2) }
	def static getMiddleBottom(Rectangle it) { new Point(x + width / 2, y + height) }
	def static getMiddleBottomLeft(Rectangle it) { new Point(x + (width / 2) - 20, y + height) }
	
	def static getMiddleRight(Rectangle it) { new Point(x + width, y + height / 2) }
	def static getMiddleLeft(Rectangle it) { new Point(x, y + height / 2) }

	def isOnTheRightOf(Point point, Point anotherPoint) {
		point.x > anotherPoint.x
	}
	
}
