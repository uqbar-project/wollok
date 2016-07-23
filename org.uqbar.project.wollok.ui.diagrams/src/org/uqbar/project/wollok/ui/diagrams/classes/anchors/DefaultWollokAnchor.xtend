package org.uqbar.project.wollok.ui.diagrams.classes.anchors

import org.eclipse.draw2d.ChopboxAnchor
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.geometry.Point
import org.eclipse.draw2d.geometry.Rectangle

class DefaultWollokAnchor extends ChopboxAnchor {
	
	new(IFigure owner) {
		super(owner)	
	}
	
	def translateToAbsolute(Point point) {
		val newPoint = point
		owner.translateToAbsolute(newPoint)
		newPoint	
	}
	
	override getReferencePoint() {
		owner.bounds.middleTop.translateToAbsolute
	}
	
	override getLocation(Point reference) {
		owner.bounds.middleBottom.translateToAbsolute
	}
	
	def getMiddleTop(Rectangle it) { new Point(x + width / 2, y) }
	def getMiddleBottom(Rectangle it) { new Point(x + width / 2, y + height) }
	
	def getMiddleRight(Rectangle it) { new Point(x + width, y + height / 2) }
	def getMiddleLeft(Rectangle it) { new Point(x, y + height / 2) }
	
}
