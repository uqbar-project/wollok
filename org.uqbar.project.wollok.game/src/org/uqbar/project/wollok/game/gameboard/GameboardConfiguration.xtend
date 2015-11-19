package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.Files.FileType;
import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration

class GameboardConfiguration extends LwjglApplicationConfiguration {
	
	new (Gameboard gameboard) {
		this.useGL30 = false;
		this.resizable = false;
		this.title = gameboard.getTittle();
		this.width = gameboard.pixelWidth();
		this.height = gameboard.pixelHeight();
		this.addIcon("flying_bird.png", FileType.Internal);
	}
}
