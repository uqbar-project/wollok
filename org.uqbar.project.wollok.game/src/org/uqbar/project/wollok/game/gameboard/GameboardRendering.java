package org.uqbar.project.wollok.game.gameboard;

import org.uqbar.project.wollok.game.VisualComponent;
import org.uqbar.project.wollok.game.listeners.GameboardListener;

import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.Texture.TextureFilter;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class GameboardRendering implements ApplicationListener {

	private Gameboard gameboard;
	private OrthographicCamera camera;
	private SpriteBatch batch;

	public GameboardRendering(Gameboard gameboard) {
		this.gameboard = gameboard;
	}

	@Override
	public void create() {
		camera = new OrthographicCamera(0, 0);
		camera.setToOrtho(false, gameboard.width(), gameboard.height());
		batch = new SpriteBatch();
	}

	@Override
	public void render() {
		batch.setProjectionMatrix(camera.combined);
		batch.begin();
		
		for (GameboardListener listener : gameboard.getListeners()) {
			listener.notify(gameboard);
		}
		
		for (Cell cell : gameboard.getCells()) {
			this.draw(cell);
		}
		
		this.draw(gameboard.getCharacter());
		
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
	
	private void draw(VisualComponent aComponent){
		Texture texture = new Texture(Gdx.files.internal(aComponent.getImage()));
		texture.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		batch.draw(texture, aComponent.getMyPosition().getXinPixels(), aComponent.getMyPosition().getYinPixels());
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

