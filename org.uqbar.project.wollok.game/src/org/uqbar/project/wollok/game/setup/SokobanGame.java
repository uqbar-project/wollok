package org.uqbar.project.wollok.game.setup;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.uqbarproject.sokoban.domain.behavior.MovementDown;
import org.uqbarproject.sokoban.domain.behavior.MovementLeft;
import org.uqbarproject.sokoban.domain.behavior.MovementRight;
import org.uqbarproject.sokoban.domain.behavior.MovementTop;
import org.uqbarproject.sokoban.domain.behavior.Position;
import org.uqbarproject.sokoban.domain.pieces.Box;
import org.uqbarproject.sokoban.domain.pieces.Element;
import org.uqbarproject.sokoban.domain.pieces.GameBoard;
import org.uqbarproject.sokoban.domain.pieces.Sokoban;
import org.uqbarproject.sokoban.domain.pieces.Wall;

import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input.Keys;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.Texture.TextureFilter;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class SokobanGame implements ApplicationListener {

	private int w;
	private int h;
	private float keyboardCounter;
	private OrthographicCamera camera;
	private SpriteBatch batch;
	private Map<String,Texture> texturas;
	private Texture almacenaje;
	private Texture suelo;
	private Texture muro;
	private Texture jugador;
	private Texture caja;
	private GameBoard gameBoard;
	private boolean marca;
	
	@Override
	public void create() {
		marca = false;
		w = Gdx.graphics.getWidth();
		h = Gdx.graphics.getHeight();
		keyboardCounter = 0;
		
		//camera = new OrthographicCamera(1, h/w);
		
		camera = new OrthographicCamera(0, 0);
		camera.setToOrtho(false, w, h);

		batch = new SpriteBatch();
		
		texturas = new HashMap<String,Texture>();
		
		almacenaje = new Texture(Gdx.files.internal("data/almacenaje.png"));
		almacenaje.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		texturas.put("almacenaje.png", almacenaje);
		suelo = new Texture(Gdx.files.internal("data/suelo.png"));
		suelo.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		texturas.put("suelo.png", suelo);
		muro = new Texture(Gdx.files.internal("data/muro.png"));
		muro.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		texturas.put("muro.png", muro);
		jugador = new Texture(Gdx.files.internal("data/jugador.png"));
		jugador.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		texturas.put("jugador.png", jugador);
		caja = new Texture(Gdx.files.internal("data/caja.png"));
		caja.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		texturas.put("caja.png", caja);
		//endScreen = new Texture(Gdx.files.internal("data/libgdx.png"));
		
		gameBoard = new GameBoard(5,6); //WarehouseMap.createWarehouse();
		Wall pared = new Wall();
		pared.setMyPosition(new Position(1,0));
		pared.setMyGameBoard(gameBoard);
		Box caja = new Box();
		caja.setMyPosition(new Position(3,2));
		caja.setMyGameBoard(gameBoard);
		Sokoban jugador = new Sokoban();
		jugador.setMyPosition(new Position(2,2));
		jugador.setMyGameBoard(gameBoard);
		gameBoard.setaPlayer(jugador);
		h -=32;
	}

	@Override
	public void resize(int width, int height) {
		// TODO Auto-generated method stub

	}

	@Override
	public void render() {
	processKeyboard();
		
		Gdx.gl.glClearColor(1, 1, 1, 1);
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		
		batch.setProjectionMatrix(camera.combined);
		batch.begin();
		
		
		for (int i = 0; i < gameBoard.getWide(); i++) {
			for (int j = 0; j < gameBoard.getHeight(); j++) {
				List<Element> lista = gameBoard.findElementByPlace(j,i);
				if (lista.isEmpty()){
					//Dibujo piso					
					batch.draw(suelo, (j*32), h - (i*32));
				}
				else{
					batch.draw(texturas.get(lista.get(0).getImageName()), (j*32), h - (i*32));
				}
					
			}
		}
		
		// Draw player
		batch.draw(texturas.get("jugador.png"), (gameBoard.getaPlayer().getMyPosition().getX()*32), h - (gameBoard.getaPlayer().getMyPosition().getY()*32));

		// check end of game
//		if (this.gameBoard.isGameOver()) {
//			//batch.draw(this.endScreen, 0,0);
//		}

		
		batch.end();
	}

	@Override
	public void pause() {
		// TODO Auto-generated method stub

	}

	@Override
	public void resume() {
		// TODO Auto-generated method stub

	}

	@Override
	public void dispose() {
		batch.dispose();
	}
	
	private void processKeyboard() {
		this.keyboardCounter += Gdx.graphics.getDeltaTime();
		if (this.keyboardCounter > 0.09f) {
			this.keyboardCounter = 0;

		if (!marca){
			Gdx.input.setCursorPosition(0, 0);
			marca = true;
		}
			
		if(Gdx.input.isKeyPressed(Keys.LEFT)) {
			this.gameBoard.getaPlayer().move(new MovementLeft(), 1);
	    	return;
	    }
	    if(Gdx.input.isKeyPressed(Keys.RIGHT)) {
	    	this.gameBoard.getaPlayer().move(new MovementRight(), 1);
	    	return;
	    }
	    if(Gdx.input.isKeyPressed(Keys.UP)) {
	    	this.gameBoard.getaPlayer().move(new MovementTop(), 1);
	    	return;
	    }
	    if(Gdx.input.isKeyPressed(Keys.DOWN)) {
	    	this.gameBoard.getaPlayer().move(new MovementDown(), 1);
	    	//this.whr.movePlayer(Movement.Down);
	    	return;
	    }
		}		
	}
}
