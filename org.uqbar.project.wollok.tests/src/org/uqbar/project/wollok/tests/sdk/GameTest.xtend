package org.uqbar.project.wollok.tests.sdk

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

class GameTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void canInstanceNewPosition() {
		'''
		assert.equals(«position(1,2)», game.at(1,2))
		'''.test
	}
	
	@Test
	def void originShouldReturnOriginCoordinatePosition() {
		'''
		assert.equals(«position(0,0)», game.origin())
		'''.test
	}
	
	@Test
	def void centerShouldReturnCenteredCoordinatePosition() {
		'''
		game.setWidth(3)
		game.setHeight(5)
		assert.equals(«position(1,2)», game.center())
		'''.test
	}
	
	private def position(int x, int y) {
		'''new Position(«x»,«y»)'''
	}
}