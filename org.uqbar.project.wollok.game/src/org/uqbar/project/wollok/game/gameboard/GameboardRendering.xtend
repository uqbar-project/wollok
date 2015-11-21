package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.GL20

class GameboardRendering implements ApplicationListener {

	private Gameboard gameboard;
	private OrthographicCamera camera;
	private SpriteBatch batch;
	private BitmapFont font;
	
	new (Gameboard gameboard) {
		this.gameboard = gameboard;
	}

	override create() {
		Gdx.input.setInputProcessor(new GameboardInputProcessor());
		camera = new OrthographicCamera(0, 0);
		camera.setToOrtho(false, gameboard.pixelWidth(), gameboard.pixelHeight());
		batch = new SpriteBatch();
		font = new BitmapFont();
	}

	override render() {
		Gdx.gl.glClearColor(1, 1, 1, 1);
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		batch.setProjectionMatrix(camera.combined);
		batch.begin();

		this.gameboard.render(batch, font)
		
		batch.end();
	}

	override dispose() {
		batch.dispose();
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