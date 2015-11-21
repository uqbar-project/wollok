package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.OrthographicCamera

class GameboardRendering implements ApplicationListener {

	private Gameboard gameboard
	private Window window
	
	new (Gameboard gameboard) {
		this.gameboard = gameboard;
	}

	override create() {
		Gdx.input.setInputProcessor(new GameboardInputProcessor());
		var camera = new OrthographicCamera(0, 0);
		camera.setToOrtho(false, gameboard.pixelWidth(), gameboard.pixelHeight())
		this.window = new Window(camera)
	}

	override render() {
		this.window.clear()

		this.gameboard.render(this.window)
		
		this.window.end()
	}

	override dispose() {
		this.window.dispose()
	}
	
	override pause() {
//		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override resize(int arg0, int arg1) {
//		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override resume() {
//		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}