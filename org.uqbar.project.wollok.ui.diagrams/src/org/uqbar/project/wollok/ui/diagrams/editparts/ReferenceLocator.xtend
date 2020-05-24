package org.uqbar.project.wollok.ui.diagrams.editparts

import org.eclipse.draw2d.Connection
import org.eclipse.draw2d.MidpointLocator
import org.eclipse.draw2d.geometry.Point

class ReferenceLocator extends MidpointLocator {
	
	new(Connection c) {
		super(c, 0)
	}
	
	override getReferencePoint() {
		val connection = getConnection()
		val p1 = connection.points.getPoint(index)
		val p2 = connection.points.getPoint(index + 1)
		connection.translateToAbsolute(p1)
		connection.translateToAbsolute(p2)
		Point.SINGLETON => [
			x = ((p2.x - p1.x) * 2) / 3 + p1.x
			y = ((p2.y - p1.y) * 2) / 3 + p1.y	
		]
	}
}

class SelfReferenceLocator extends MidpointLocator {

	new(Connection c) {
		super(c, 0)
	}
	
	override getReferencePoint() {
		val connection = getConnection()
		val originalReferencePoint = connection.points.getPoint(index)
		connection.translateToAbsolute(originalReferencePoint)
		Point.SINGLETON => [
			x = originalReferencePoint.x + 20
			y = originalReferencePoint.y + 12
		]
	}
	
}