package org.uqbar.project.wollok.tests.game

import org.junit.Test
import org.uqbar.project.wollok.game.GameSize
import org.uqbar.project.wollok.game.gameboard.CellsBackground
import org.uqbar.project.wollok.game.gameboard.FullBackground
import org.uqbar.project.wollok.game.gameboard.Gameboard

import static org.junit.Assert.*

class BackgroundTest {
	val path = "image.png"
	val gameboard = new Gameboard
	
	@Test
	def void cells_background_should_create_all_board_cells() {
		new CellsBackground(path, gameboard) => [
			assertEquals(5 * 5, cells.size)
		]
	}
	
	@Test
	def void full_background_should_create_game_size_image() {
		new FullBackground(path, gameboard) => [
			assertTrue(image.size instanceof GameSize)	
		]
	}	
}