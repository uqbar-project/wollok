package org.uqbar.project.wollok.game.helpers

import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.gameboard.WollokGDXApplication
import com.badlogic.gdx.Gdx

class Application {
	var static Application instance
	
	def static getInstance() {
		if (instance === null)
			instance = new Application()
			
		instance
	}
	
	// For testing TODO: use DI
	def static setInstance(Application app) {
		instance = app
	}
	
	def void start(Gameboard game, Boolean fromREPL) {
		new WollokGDXApplication(game, fromREPL)
	}
	
	def void stop() {
		Gdx.app.exit
	}
}