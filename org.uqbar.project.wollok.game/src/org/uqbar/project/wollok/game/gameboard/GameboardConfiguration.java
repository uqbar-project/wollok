package org.uqbar.project.wollok.game.gameboard;

import com.badlogic.gdx.Files.FileType;
import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration;

public class GameboardConfiguration extends LwjglApplicationConfiguration {

	public GameboardConfiguration(Gameboard gameboard) {
		this.useGL30 = false;
		this.title = gameboard.getTittle();
		this.width = gameboard.width();
		this.height = gameboard.height();
		this.addIcon("flying_bird.png", FileType.Internal);
	}

}
