package org.uqbar.project.wollok.tests.game;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.uqbar.project.wollok.game.gameboard.Gameboard;

public class GameboardTest {

	private Gameboard aGameBoard2x5;

	@Before
	public void init(){
		this.aGameBoard2x5 = new Gameboard();
		this.aGameBoard2x5.setTittle("UnTìtulo");
		this.aGameBoard2x5.setCantCellX(2);
		this.aGameBoard2x5.setCantCellY(5);
	}
	
	@Test
	public void on_initialize_create_all_cells() {
		Assert.assertEquals(10, this.aGameBoard2x5.getCells().size());
	}
}
