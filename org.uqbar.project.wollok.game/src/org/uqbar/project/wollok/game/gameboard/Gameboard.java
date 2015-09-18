package org.uqbar.project.wollok.game.gameboard;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.uqbar.project.wollok.game.GameConfiguration;
import org.uqbar.project.wollok.game.GameFactory;
import org.uqbar.project.wollok.game.Position;
import org.uqbar.project.wollok.game.VisualComponent;
import org.uqbar.project.wollok.game.listeners.ArrowListener;
import org.uqbar.project.wollok.game.listeners.GameboardListener;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.backends.lwjgl.LwjglApplication;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.google.common.base.Predicate;
import com.google.common.collect.Collections2;

public class Gameboard {
	
	public static final int CELLZISE = 50;
	private String tittle;
	private int cantCellX;
	private int cantCellY;

	private GameConfiguration configuration;
	private List<Cell> cells = new ArrayList<Cell>();
	private VisualComponent character;
	private List<VisualComponent> components = new ArrayList<VisualComponent>();

	public Gameboard() {
		GameFactory factory = new GameFactory();
		factory.setGame(this);
		//this.setStage(new Stage());
	}

	public void createCells(String groundImage) {
		for (int i = 0; i < configuration.getGameboardWidth(); i++) {
			for (int j = 0; j < configuration.getGameboardHeight(); j++) {
				cells.add(new Cell(i * CELLZISE, j * CELLZISE, groundImage));
			}
		}
	}

	public void start() {
		new LwjglApplication(new GameboardRendering(this), new GameboardConfiguration(this));
	}
	
	public int height() {
		return getCantCellY() * CELLZISE;
	}

	public int width() {
		return getCantCellX() * CELLZISE;
	}
	
	public boolean isKeyPressed(int key) {
		return Gdx.input.isKeyJustPressed(key);
	}
	
	public void addComponent(VisualComponent component) {
		this.components.add(component);
	}

	public Collection<VisualComponent> getComponentsInPosition(Position myPosition) {
		return Collections2.filter(components, new IsEqualPosition(myPosition));
	}

	public Collection<VisualComponent> getComponentsInPosition(int xInPixels, int yInPixels) {
		yInPixels = Gameboard.getInstance().height() - yInPixels;
		return Collections2.filter(components, new IsEqualPosition(xInPixels,yInPixels));
	}
	
	// Getters & Setters
	public VisualComponent getCharacter() {
		return character;
	}

	public void addCharacter(VisualComponent character) {
		this.character = character;
		this.configuration.addListener(new ArrowListener(this));
	}
	public VisualComponent getCharacterVisualcomponent(){
		return this.character;
	}

	public String getTittle() {
		return configuration.getGameboardTitle();
	}
	
	public List<Cell> getCells() {
		return cells;
	}

	public List<GameboardListener> getListeners() {
		return this.configuration.getListeners();
	}
	
	public List<VisualComponent> getComponents() {
		return this.components;
	}

	public void serListeners(List<GameboardListener> aList){
		this.configuration.setListeners(aList);
	}
	public void addListener(GameboardListener aListener){
		this.configuration.getListeners().add(aListener);
	}

	public void setComponents(List<VisualComponent> components) {
		this.components = components;
	}

	public int getCantCellX() {
		return cantCellX;
	}

	public void setCantCellX(int cantCellX) {
		this.cantCellX = cantCellX;
	}

	public void setCantCellY(int cantCellY) {
		this.cantCellY = cantCellY;
	}

	public int getCantCellY() {
		return configuration.getGameboardHeight();
	}
	
	private class IsEqualPosition implements Predicate<VisualComponent>{

		private Position myPosition;

		public IsEqualPosition(int x, int y){
			
			this.myPosition = new Position();
			this.myPosition.setX(x/Gameboard.CELLZISE);
			this.myPosition.setY(y/Gameboard.CELLZISE);
		}
		
		public IsEqualPosition(Position p) {
			this.myPosition = p;
		}

		@Override
		public boolean apply(VisualComponent it) {
			return it.getPosition().equals(myPosition);
		}
		
	}

	private static Gameboard instance;
	public static Gameboard getInstance() {
	  if(instance == null)
		  instance = new Gameboard();
	  return instance;
	}

	public GameConfiguration getConfiguration() {
		return configuration;
	}

	public void setConfiguration(GameConfiguration configuration) {
		this.configuration = configuration;
	}

	public void clear() {
		this.components.clear();
		this.configuration.getListeners().clear();
	}
}

