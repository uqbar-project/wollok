package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.OrthographicCamera

class GameboardRendering implements ApplicationListener {

	Gameboard gameboard
	Window window
	
	new (Gameboard gameboard) {
		this.gameboard = gameboard
	}

	override create() {
		Gdx.input.setInputProcessor(new GameboardInputProcessor())
		val camera = new OrthographicCamera(0, 0)
		camera.setToOrtho(false, gameboard.pixelWidth(), gameboard.pixelHeight())
		this.window = new Window(camera)
	}

	override render() {
		this.window.clear()
		this.gameboard.draw(this.window)
		this.window.end()
	}

	override dispose() {
		this.window.dispose()
	}
	
	override pause() {
	}
	
	override resize(int arg0, int arg1) {
	}
	
	override resume() {
	}
}