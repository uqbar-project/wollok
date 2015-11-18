package org.uqbar.project.wollok.game.gameboard;

import java.util.ArrayList;
import java.util.List;

import org.uqbar.project.wollok.game.GameConfiguration;
import org.uqbar.project.wollok.game.GameFactory;
import org.uqbar.project.wollok.game.Position;
import org.uqbar.project.wollok.game.VisualComponent;
import org.uqbar.project.wollok.game.listeners.ArrowListener;
import org.uqbar.project.wollok.game.listeners.GameboardListener;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.backends.lwjgl.LwjglApplication;
import com.google.common.base.Predicate;
import com.google.common.collect.Collections2;
import java.util.Collection

class Gameboard {

	public static Gameboard instance;
	public static final int CELLZISE = 50;
	private GameConfiguration configuration;
	private List<Cell> cells = new ArrayList<Cell>();
	private VisualComponent character;
	public List<VisualComponent> components = new ArrayList<VisualComponent>();
	
	def static getInstance() {
		if (instance == null) {
			instance = new Gameboard()
			new GameFactory().setGame(instance)
		}
		return instance
	}

	def createCells(String groundImage) {
		for (var i = 0; i < configuration.getGameboardWidth(); i++) {
			for (var j = 0; j < configuration.getGameboardHeight(); j++) {
				cells.add(new Cell(i * CELLZISE, j * CELLZISE, groundImage));
			}
		}
	}

	def void start() {
		new LwjglApplication(new GameboardRendering(this), new GameboardConfiguration(this));
	}

	def height() {
		return this.getCantCellY() * CELLZISE;
	}

	def width() {
		return getCantCellX() * CELLZISE;
	}

	def isKeyPressed(int key) {
		return Gdx.input.isKeyJustPressed(key);
	}
	
	def clear() {
		this.components.clear();
		this.configuration.getListeners().clear();
	}

	def characterSay(String aText) {
		this.character.say(aText);
	}

	// Getters & Setters
	
	def getComponentsInPosition(Position myPosition) {
		return Collections2.filter(components, new IsEqualPosition(myPosition));
	}
	
	def getComponentsInPosition(int xInPixels, int yInPixels) {
		var inverseYInPixels = Gameboard.getInstance().height() - yInPixels;
		return Collections2.filter(components, new IsEqualPosition(xInPixels,inverseYInPixels));
	}

	def addComponent(VisualComponent component) {
		this.components.add(component);
	}
	
	def addComponents(Collection<VisualComponent> components) {
		this.components.addAll(components);
	}
	
	def getCharacter() {
		return character;
	}

	def addCharacter(VisualComponent character) {
		this.character = character;
		this.configuration.addListener(new ArrowListener(this));
	}

	def getTittle() {
		return configuration.getGameboardTitle();
	}

	def getCells() {
		return cells;
	}

	def getListeners() {
		return this.configuration.getListeners();
	}

	def getComponents() {
		var allComponents = new ArrayList<VisualComponent>(this.components);
		if (character != null)
			allComponents.add(this.character);
		return allComponents;
	}

	def addListener(GameboardListener aListener){
		this.configuration.getListeners().add(aListener);
	}
	
	def getCantCellX() {
		return configuration.getGameboardWidth();
	}

	def getCantCellY() {
		return configuration.getGameboardHeight();
	}
	
	def getConfiguration() {
		return configuration;
	}
	
	def setConfiguration(GameConfiguration configuration) {
		this.configuration = configuration;
	}
}

class IsEqualPosition implements Predicate<VisualComponent> {

	Position myPosition;

	new (int x, int y){
		
		this.myPosition = new Position();
		this.myPosition.setX(x/Gameboard.CELLZISE);
		this.myPosition.setY(y/Gameboard.CELLZISE);
	}
	
	new (Position p) {
		this.myPosition = p;
	}

	override apply(VisualComponent it) {
		return it.getPosition().equals(myPosition);
	}

}
