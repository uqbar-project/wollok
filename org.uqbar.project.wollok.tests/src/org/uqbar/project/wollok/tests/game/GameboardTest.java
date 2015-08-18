package org.uqbar.project.wollok.tests.game;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.uqbar.project.wollok.game.GameConfiguration;
import org.uqbar.project.wollok.game.gameboard.Gameboard;

public class GameboardTest {

	private Gameboard aGameBoard2x5;

	@Before
	public void init(){
		this.aGameBoard2x5 = new Gameboard();
		GameConfiguration config = new GameConfiguration();
		config.setGameboardTitle("UnTìtulo");
		config.setGameboardWidth(2);
		config.setGameboardHeight(5);
		this.aGameBoard2x5.setConfiguration(config);		
	}
	
	@Test
	public void on_initialize_create_all_cells() {
		Assert.assertEquals(10, this.aGameBoard2x5.getCells().size());
	}
}
