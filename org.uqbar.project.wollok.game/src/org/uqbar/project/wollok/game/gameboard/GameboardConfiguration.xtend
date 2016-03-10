package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration

class GameboardConfiguration extends LwjglApplicationConfiguration {

	new(Gameboard gameboard) {
		this.useGL30 = false
		this.resizable = false
		this.title = gameboard.title
		this.width = gameboard.pixelWidth()
		this.height = gameboard.pixelHeight()
	}
}
