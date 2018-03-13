package org.uqbar.project.wollok.tests.game

import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.CellSize
import org.uqbar.project.wollok.game.GameSize
import org.uqbar.project.wollok.game.TextureSize
import org.uqbar.project.wollok.game.gameboard.Gameboard

import static org.junit.Assert.*

class ImageTest {
	var Gameboard gameboard 
	
	@Before
	def void init() {
		gameboard = new Gameboard => [ 
			width = 3
			height = 4
		]
	}
	
	@Test
	def void texture_size_should_return_texture_dimensions() {
		new TextureSize => [
			assertEquals(10, width(10))
			assertEquals(20, height(20))
		]
	}
	
	@Test
	def void cell_size_should_return_cell_dimensions() {
		new CellSize(50) => [
			assertEquals(50, width(10))
			assertEquals(50, height(20))
		]
	}
	
	@Test
	def void game_size_should_return_game_dimensions() {
		new GameSize(gameboard) => [
			assertEquals(3 * 50, width(10))
			assertEquals(4 * 50, height(20))
		]
	}
}