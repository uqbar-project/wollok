package org.uqbar.project.gef

import org.eclipse.draw2d.AbstractRouter
import org.eclipse.draw2d.Connection
import org.eclipse.draw2d.ConnectionAnchor
import org.eclipse.draw2d.geometry.Point
import org.eclipse.draw2d.geometry.PointList
import org.uqbar.project.wollok.ui.diagrams.classes.anchors.DefaultWollokAnchor
import org.uqbar.project.wollok.ui.diagrams.classes.anchors.SelfReferenceAnchor

/**
 * Routes the connection in a tree-like form unifying connections
 * 
 *         _____________
 *        |             |
 *         -------------
 *               ^
 *               |
 *               |
 *     (A*)-----(B*)-----------+-----------------
 *      |                |                |
 *   ________         ________         ________
 *  |        |       |        |       |        |
 *   --------         --------         --------
 * 
 * All incoming connections to a target node will converge into a single point in the middle
 * of the figure.
 * Connections have 2 intermediate points:
 *    * A*: 1 to break the line and adjust the "y" coordinate (starts to go down / up until the middle of the target figure)
 *    * B*: to stop adjusting y and then moving forward to the end point 
 * 
 * @author jfernandes
 * 
 * Enhancement: delegates to every kind of node
 */
// currently only works fine for LEFT to RIGHT diagrams
class SquareConnectionRouter extends AbstractRouter {
	public static val DISTANCE_FROM_TARGET = 20
	Point startPoint 
	Point endPoint
	
	override route(Connection conn) {
		if (conn.sourceAnchor == null || conn.targetAnchor == null)
			return;

		startPoint = getStartPoint(conn)
		conn.translateToRelative(startPoint)
		endPoint = getEndPoint(conn)
		conn.translateToRelative(endPoint)
		
		if (!startPoint.equals(endPoint)) {
			conn.points = new PointList => [
				addPoint(startPoint)
				// go up
				addPoint(new Point(startPoint.x, endPoint.y + DISTANCE_FROM_TARGET))
				// go right
				addPoint(new Point(endPoint.x, endPoint.y + DISTANCE_FROM_TARGET))
				addPoint(endPoint)
			]
		}
	}
	
	override protected getStartPoint(Connection conn) {
		if (conn.sourceAnchor === conn.targetAnchor) {
			return new SelfReferenceAnchor(conn.sourceAnchor.owner).referencePoint
		}
		if (conn.sourceAnchor?.below(conn.targetAnchor)) {
			return new DefaultWollokAnchor(conn.sourceAnchor.owner).referencePoint	
		}
		conn.sourceAnchor.referencePoint
	}
	
	override protected getEndPoint(Connection conn) {
		if (conn.sourceAnchor === conn.targetAnchor) {
			return new SelfReferenceAnchor(conn.sourceAnchor.owner).getLocation(endPoint)
		}
		conn.targetAnchor?.getLocation(endPoint)
	}

	def boolean below(ConnectionAnchor source, ConnectionAnchor target) {
		source.owner.bounds.top.y > target.owner.bounds.bottom()
	}
	
}
