package org.uqbar.project.wollok.game.gameboard;

import com.badlogic.gdx.backends.lwjgl.LwjglApplication
import java.util.ArrayList
import java.util.Collection
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.GameboardFactory
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.listeners.ArrowListener
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

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

	def void start() {
		new LwjglApplication(new GameboardRendering(this), new GameboardConfiguration(this));
	}
	
	def void draw(Window window) {
		// NO UTILIZAR FOREACH PORQUE HAY UN PROBLEMA DE CONCURRENCIA AL MOMENTO DE VACIAR LA LISTA
		for (var i=0; i < this.listeners.size(); i++){
			try {
				this.listeners.get(i).notify(this);
			} 
			catch (WollokProgramExceptionWrapper e) {
				var message = e.getWollokException().getInstanceVariables().get("message");
				if (message == null)
					message = "NO MESSAGE";
				
				if (character != null)
					character.scream("ERROR: " + message.toString());
			} 
		}

		this.cells.forEach[ it.draw(window) ]

		this.getComponents().forEach[ it.draw(window) ]		
	}

	def createCells(String groundImage) {
		for (var i = 0; i < height; i++) {
			for (var j = 0; j < width; j++) {
				cells.add(new Cell(new Position(i, j), new Image(groundImage)));
			}
		}
	}

	def pixelHeight() {
		return height * CELLZISE;
	}

	def pixelWidth() {
		return width * CELLZISE;
	}
	
	def clear() {
		this.components.clear();
		this.listeners.clear();
	}

	def characterSay(String aText) {
		this.character.say(aText);
	}
	
	def getComponentsInPosition(Position position) {
		return this.getComponents().filter [it.position.equals(position)]
	}

	// Getters & Setters

	def addCharacter(VisualComponent character) {
		this.character = character;
		this.addListener(new ArrowListener(character));
	}

	def addComponent(VisualComponent component) {
		this.components.add(component);
	}
	
	def addComponents(Collection<VisualComponent> components) {
		this.components.addAll(components);
	}

	def addListener(GameboardListener aListener){
		this.listeners.add(aListener);
	}

	def getComponents() {
		var others = #{}
		if (character != null)
			others = #{character}
		components + others
	}
}
