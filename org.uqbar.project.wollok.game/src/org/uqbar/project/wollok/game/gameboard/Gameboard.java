package org.uqbar.project.wollok.game.gameboard;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.stream.Stream;

import org.uqbar.project.wollok.game.Position;
import org.uqbar.project.wollok.game.VisualComponent;
import org.uqbar.project.wollok.game.listeners.GameboardListener;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.backends.lwjgl.LwjglApplication;
import com.google.common.base.Predicate;
import com.google.common.collect.Collections2;

public class Gameboard {
	
	private static final int CELLZISE = 50;
	private String tittle;
	private int cantCellX;
	private int cantCellY;
	private List<Cell> cells = new ArrayList<Cell>();
	private List<GameboardListener> listeners = new ArrayList<GameboardListener>();
	private List<VisualComponent> components = new ArrayList<VisualComponent>();
	
	public Gameboard(){
		
	}
	
	private void createCells(int cantCellX, int cantCellY) {
		for (int i = 0; i < cantCellX; i++) {
			for (int j = 0; j < cantCellY; j++) {
				cells.add(new Cell(i*CELLZISE, j*CELLZISE));
			}
		}
	}

	public void start() {
		this.createCells(cantCellX, cantCellY);
		new LwjglApplication(new GameboardRendering(this), new GameboardConfiguration(this));
	}
	
	public int height() {
		return getCantCellY() * CELLZISE;
	}

	public int width() {
		return getCantCellX() * CELLZISE;
	}
	
	public boolean isKeyPressed(int key) {
		return Gdx.input.isKeyPressed(key);
	}
	
	public Collection<VisualComponent> getComponentsInPosition(Position myPosition) {
		
		return Collections2.filter(components, new IsEqualPosition(myPosition));
	}
	
	// Getters & Setters
	public String getTittle() {
		return tittle;
	}
	
	public List<Cell> getCells() {
		return cells;
	}

	public List<GameboardListener> getListeners() {
		return listeners;
	}
	
	public List<VisualComponent> getComponents() {
		return this.components;
	}

	public void setComponents(List<VisualComponent> components) {
		this.components = components;
	}

	public void setTittle(String tittle) {
		this.tittle = tittle;
	}

	public int getCantCellX() {
		return cantCellX;
	}

	public void setCantCellX(int cantCellX) {
		this.cantCellX = cantCellX;
	}

	public int getCantCellY() {
		return cantCellY;
	}

	public void setCantCellY(int cantCellY) {
		this.cantCellY = cantCellY;
	}
	
	private class IsEqualPosition implements Predicate<VisualComponent>{

		private Position myPosition;
		public IsEqualPosition(Position p) {
			this.myPosition = p;
		}
		@Override
		public boolean apply(VisualComponent it) {
			return it.getMyPosition().equals(myPosition);
		}
		
	}

	private static Gameboard instance;
	public static Gameboard getInstance() {
	  if(instance == null)
		  instance = new Gameboard();
	  return instance;
	}
}

