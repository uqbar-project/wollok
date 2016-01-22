package org.uqbar.project.wollok.game.gameboard;

import com.badlogic.gdx.Gdx
import java.util.Collection
import java.util.List
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.listeners.ArrowListener
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.game.WGPosition
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * 
 */
@Accessors
class Gameboard {
	public static Gameboard instance
	public static final int CELLZISE = 50
	
	String title
	int height
	int width
	List<Cell> cells = newArrayList
	List<VisualComponent> components = newArrayList
	List<GameboardListener> listeners = newArrayList
	VisualComponent character
	
	def static getInstance() {
		if (instance == null) {
			instance = new Gameboard()
		}
		return instance
	}

	def void start() {
		new WollokGDXApplication(new GameboardRendering(this), new GameboardConfiguration(this))
		Runtime.runtime.addShutdownHook(new Thread([
			Gdx.app.exit
		]))
	}
	
	def void draw(Window window) {
		// NO UTILIZAR FOREACH PORQUE HAY UN PROBLEMA DE CONCURRENCIA AL MOMENTO DE VACIAR LA LISTA
		for (var i=0; i < this.listeners.size(); i++){
			try {
				this.listeners.get(i).notify(this);
			} 
			catch (WollokProgramExceptionWrapper e) {
				var Object message = e.wollokMessage
				if (message == null)
					message = "NO MESSAGE"
				
				if (character != null)
					character.scream("ERROR: " + message.toString())
					
				System.out.println(e.wollokStackTrace)
			} 
		}

		this.cells.forEach[ it.draw(window) ]

		this.getComponents().forEach[ it.draw(window) ]		
	}

	def createCells(String groundImage) {
		for (var i = 0; i < height; i++) {
			for (var j = 0; j < width; j++) {
				cells.add(new Cell(new WGPosition(i, j), new Image(groundImage)));
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
		components.clear()
		listeners.clear()
		character = null
	}

	def characterSay(String aText) {
		character.say(aText);
	}
	
	def getComponentsInPosition(Position p) {
		this.getComponents.filter [
			position == p
		]
	}

	// Getters & Setters

	def addCharacter(VisualComponent character) {
		this.character = character
		addComponent(character)
		addListener(new ArrowListener(character))
	}

	def addComponent(VisualComponent component) {
		components.add(component)
	}
	
	def addComponents(Collection<VisualComponent> it) {
		components.addAll(it)
	}

	def addListener(GameboardListener aListener){
		listeners.add(aListener);
	}
	
	def remove(VisualComponent component) {
		components.remove(component)
	}
	
}
