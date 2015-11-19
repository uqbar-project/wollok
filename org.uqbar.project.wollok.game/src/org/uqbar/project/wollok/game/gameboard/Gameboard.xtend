package org.uqbar.project.wollok.game.gameboard;

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.backends.lwjgl.LwjglApplication

import com.google.common.base.Predicate
import com.google.common.collect.Collections2

import java.util.ArrayList
import java.util.Collection
import java.util.List

import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.listeners.ArrowListener
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.game.GameboardFactory
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Gameboard {

	public static Gameboard instance;
	public static final int CELLZISE = 50
	private VisualComponent character
	private List<Cell> cells = new ArrayList<Cell>()
	
	public String title
	public int height
	public int width
	public List<VisualComponent> components = new ArrayList<VisualComponent>()
	public List<GameboardListener> listeners = new ArrayList<GameboardListener>()
	
	def static getInstance() {
		if (instance == null) {
			instance = new Gameboard()
			GameboardFactory.setGame(instance)
		}
		return instance
	}

	def createCells(String groundImage) {
		for (var i = 0; i < height; i++) {
			for (var j = 0; j < width; j++) {
				cells.add(new Cell(i * CELLZISE, j * CELLZISE, groundImage));
			}
		}
	}

	def void start() {
		new LwjglApplication(new GameboardRendering(this), new GameboardConfiguration(this));
	}

	def pixelHeight() {
		return height * CELLZISE;
	}

	def pixelWidth() {
		return width * CELLZISE;
	}

	def isKeyPressed(int key) {
		return Gdx.input.isKeyJustPressed(key);
	}
	
	def clear() {
		this.components.clear();
		this.listeners.clear();
	}

	def characterSay(String aText) {
		this.character.say(aText);
	}
	
	def getComponentsInPosition(Position myPosition) {
		return Collections2.filter(components, new IsEqualPosition(myPosition));
	}
	
	def getComponentsInPosition(int xInPixels, int yInPixels) {
		var inverseYInPixels = Gameboard.getInstance().pixelHeight() - yInPixels;
		return Collections2.filter(components, new IsEqualPosition(xInPixels,inverseYInPixels));
	}

	// Getters & Setters

	def addComponent(VisualComponent component) {
		this.components.add(component);
	}
	
	def addComponents(Collection<VisualComponent> components) {
		this.components.addAll(components);
	}

	def addCharacter(VisualComponent character) {
		this.character = character;
		this.addListener(new ArrowListener(this));
	}

	def addListener(GameboardListener aListener){
		this.listeners.add(aListener);
	}

	def getComponents() {
		var allComponents = new ArrayList<VisualComponent>(this.components);
		if (character != null)
			allComponents.add(this.character);
		return allComponents;
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
