package org.uqbar.project.wollok.tests.sdk

import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test
import org.junit.Before

class GameTest extends AbstractWollokInterpreterTestCase {
	
	var gameboard = Gameboard.getInstance
	
	@Before
	def void init() {
		gameboard.clear
	}
	
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
		game.width(2)
		game.height(5)
		assert.equals(«position(1,2)», game.center())
		'''.test
	}
	
	@Test
	def void shouldReturnVisualColliders() {
		'''
		import wollok.game.*
		
		object myVisual { }
		class Visual { }
		
		program a {
			«position(0,0)».drawElement(myVisual)
			2.times{ i => «position(0,0)».drawElement(new Visual()) }
			«position(0,1)».drawElement(new Visual())
			
			assert.equals(2, game.colliders(myVisual).size())
		}
		'''.interpretPropagatingErrors
	}
	
	private def position(int x, int y) {
		'''new Position(«x»,«y»)'''
	}
}