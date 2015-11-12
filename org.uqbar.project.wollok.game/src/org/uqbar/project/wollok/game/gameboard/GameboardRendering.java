package org.uqbar.project.wollok.game.gameboard;

import org.uqbar.project.wollok.game.VisualComponent;
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper;

import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.Texture.TextureFilter;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class GameboardRendering implements ApplicationListener {

	private Gameboard gameboard;
	private OrthographicCamera camera;
	private SpriteBatch batch;
	private BitmapFont font;
	
	
	public GameboardRendering(Gameboard gameboard) {
		this.gameboard = gameboard;
	}

	@Override
	public void create() {;
		Gdx.input.setInputProcessor(new GameboardInputProcessor());
		camera = new OrthographicCamera(0, 0);
		camera.setToOrtho(false, gameboard.width(), gameboard.height());
		batch = new SpriteBatch();
		font = new BitmapFont();
	}

	@Override
	public void render() {
		Gdx.gl.glClearColor(1, 1, 1, 1);
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		batch.setProjectionMatrix(camera.combined);
		batch.begin();

		// NO UTILIZAR FOREACH PORQUE HAY UN PROBLEMA DE CONCURRENCIA AL MOMENTO DE VACIAR LA LISTA
		for (int i=0; i < gameboard.getListeners().size(); i++){
			try {
				gameboard.getListeners().get(i).notify(gameboard);
			} 
			catch (WollokProgramExceptionWrapper e) {
				Object message = e.getWollokException().getInstanceVariables().get("message");
				if (message == null)
					message = "NO MESSAGE";
				
				VisualComponent character = gameboard.getCharacter();
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

		if (gameboard.getCharacter()!= null && gameboard.hasMessages()){
			this.draw(gameboard.getCharacter());
			balloon.draw(batch,gameboard.getCurrentMessage());
		}
		
		batch.end();
	}

	@Override
	public void dispose() {
		batch.dispose();
	}

	private void draw(Cell cell) {
		Texture texture = new Texture(Gdx.files.internal(cell.element));
		texture.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		batch.draw(texture, cell.width, cell.height);
	}

	private void draw(VisualComponent aComponent) {
		aComponent.draw(batch, font);
	}

	@Override
	public void resize(int arg0, int arg1) {
		// TODO Auto-generated method stub

	}

	@Override
	public void resume() {
		// TODO Auto-generated method stub

	}

	@Override
	public void pause() {
		// TODO Auto-generated method stub

	}

}
