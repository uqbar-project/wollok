package org.uqbar.project.gef

import org.eclipse.draw2d.AbstractRouter
import org.eclipse.draw2d.Connection
import org.eclipse.draw2d.geometry.Point
import org.eclipse.draw2d.geometry.PointList
import org.eclipse.draw2d.geometry.Rectangle

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
 */
// currently only works fine for LEFT to RIGHT diagrams
class SquareConnectionRouter extends AbstractRouter {
	public static val DISTANCE_FROM_TARGET = 20
	
	override route(Connection conn) {
		if (conn.sourceAnchor == null || conn.targetAnchor == null)
			return
		
		val startPoint = getStartPoint(conn)
		conn.translateToRelative(startPoint)
		val endPoint = getEndPoint(conn)
		conn.translateToRelative(endPoint)
		
		conn.points = new PointList => [
			addPoint(startPoint)
			// go up
			addPoint(new Point(startPoint.x, endPoint.y + DISTANCE_FROM_TARGET))
			// go right
			addPoint(new Point(endPoint.x, endPoint.y + DISTANCE_FROM_TARGET))
			addPoint(endPoint)
		]
	}
	
	override protected getStartPoint(Connection conn) {
		conn.sourceAnchor.owner.bounds.middleTop
	}
	
	override protected getEndPoint(Connection conn) {
		conn.targetAnchor?.owner?.bounds?.middleBottom
	}
	
	def getMiddleTop(Rectangle it) { new Point(x + width / 2, y) }
	def getMiddleBottom(Rectangle it) { new Point(x + width / 2, y + height) }
	
	def getMiddleRight(Rectangle it) { new Point(x + width, y + height / 2) }
	def getMiddleLeft(Rectangle it) { new Point(x, y + height / 2) }
	
}