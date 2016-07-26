package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.backends.lwjgl.LwjglApplication

class WollokGDXApplication extends LwjglApplication {
	
	new(Gameboard gameboard, Boolean fromREPL) {
		super(new GameboardRendering(gameboard), new GameboardConfiguration(gameboard))
		if (!fromREPL) mainLoopThread.join
	}
	
}