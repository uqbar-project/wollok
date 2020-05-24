package org.uqbar.project.wollok.ui.diagrams.editparts

import org.eclipse.draw2d.Connection
import org.eclipse.draw2d.MidpointLocator
import org.eclipse.draw2d.geometry.Point

class ReferenceLocator extends MidpointLocator {
	
	new(Connection c) {
		super(c, 0)
	}
	
	override getReferencePoint() {
		val Connection conn = getConnection()
		val Point p1 = conn.points.getPoint(index)
		val Point p2 = conn.points.getPoint(index + 1)
		conn.translateToAbsolute(p1)
		conn.translateToAbsolute(p2)
		val Point p = Point.SINGLETON
		p.x = ((p2.x - p1.x) * 2) / 3 + p1.x
		p.y = ((p2.y - p1.y) * 2) / 3 + p1.y
		return p
	}
}

class SelfReferenceLocator extends MidpointLocator {

	new(Connection c) {
		super(c, 0)
	}
	
	override getReferencePoint() {
		val Connection conn = getConnection()
		val Point p1 = conn.points.getPoint(index)
		conn.translateToAbsolute(p1)
		val Point p = Point.SINGLETON
		p.x = p1.x + 20
		p.y = p1.y + 12
		return p
	}
	
}