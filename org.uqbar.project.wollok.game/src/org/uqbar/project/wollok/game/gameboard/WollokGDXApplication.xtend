package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.backends.lwjgl.LwjglApplication
import com.badlogic.gdx.ApplicationLogger

class WollokGDXApplication extends LwjglApplication {
	
	ApplicationLogger logger
	
	new(Gameboard gameboard, Boolean fromREPL) {
		super(new GameboardRendering(gameboard), new GameboardConfiguration(gameboard))
		if (!fromREPL) mainLoopThread.join
	}
	
	override getApplicationLogger() {
		logger
	}
	
	override setApplicationLogger(ApplicationLogger logger) {
		this.logger = logger
	}
	
}