package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.GL20
import com.badlogic.gdx.graphics.Texture.TextureFilter;
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.game.VisualComponent

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
		camera.setToOrtho(false, gameboard.width(), gameboard.height());
		batch = new SpriteBatch();
		font = new BitmapFont();
	}

	override render() {
		Gdx.gl.glClearColor(1, 1, 1, 1);
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		batch.setProjectionMatrix(camera.combined);
		batch.begin();

		// NO UTILIZAR FOREACH PORQUE HAY UN PROBLEMA DE CONCURRENCIA AL MOMENTO DE VACIAR LA LISTA
		for (var i=0; i < gameboard.getListeners().size(); i++){
			try {
				gameboard.getListeners().get(i).notify(gameboard);
			} 
			catch (WollokProgramExceptionWrapper e) {
				var message = e.getWollokException().getInstanceVariables().get("message");
				if (message == null)
					message = "NO MESSAGE";
				
				var character = gameboard.getCharacter();
				if (character != null)
					character.scream("ERROR: " + message.toString());
			} 

		}

		for (Cell cell : gameboard.getCells()) {
			this.draw(cell);
		}

		for (VisualComponent component : gameboard.getComponents()) {
			this.draw(component);
		}

		batch.end();
	}

	override dispose() {
		batch.dispose();
	}

	def draw(Cell cell) {
		var texture = cell.getTexture();
		texture.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		batch.draw(texture, cell.getWidth(), cell.getHeight());
	}

	def draw(VisualComponent aComponent) {
		aComponent.draw(batch, font);
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