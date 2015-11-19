package org.uqbar.project.wollok.tests.game

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.uqbar.project.wollok.game.GameConfiguration;
import org.uqbar.project.wollok.game.gameboard.Gameboard;

class GameboardTest {
	
	Gameboard gameBoard2x5;

	@Before
	def void init(){
		gameBoard2x5 = new Gameboard()
		gameBoard2x5.title = "UnTìtulo"
		gameBoard2x5.width = 2
		gameBoard2x5.height = 5
	}
	
	@Test
	def can_create_all_cells() {
		gameBoard2x5.createCells("UnaImagen")
		Assert.assertEquals(10, gameBoard2x5.cells.size());
	}	
}