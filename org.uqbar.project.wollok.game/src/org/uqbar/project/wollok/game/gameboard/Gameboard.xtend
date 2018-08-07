package org.uqbar.project.wollok.game.gameboard;

import java.util.Collection
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.helpers.Application
import org.uqbar.project.wollok.game.listeners.ArrowListener
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

@Accessors
class Gameboard {
	public static Gameboard instance
	public static final int CELLZISE = 50
	
	val Logger log = Logger.getLogger(this.class)	
	
	String title
	String ground
	String boardGround
	int height
	int width
	Background background
	List<VisualComponent> components = newArrayList
	List<GameboardListener> listeners = newArrayList
	VisualComponent character
	
	def static getInstance() {
		if (instance === null) {
			instance = new Gameboard()
		}
		return instance
	}
	
	new() {
		title = "Wollok Game"
		height = 5
		width = 5
		ground = "ground.png" 
	}
	
	def void start() {
		start(false)
	}

	def void start(Boolean fromREPL) {
		background = createBackground()
		Application.instance.start(this, fromREPL)
	}
	
	def createBackground() {
		if (boardGround !== null)
		 	new FullBackground(boardGround, this)
		else 
			new CellsBackground(ground, this)
	}
	
	def void stop() {
		Application.instance.stop
	}
	
	def void draw(Window window) {
		// NO UTILIZAR FOREACH PORQUE HAY UN PROBLEMA DE CONCURRENCIA AL MOMENTO DE VACIAR LA LISTA
		for (var i=0; i < listeners.size(); i++) {
			try 
				listeners.get(i).notify(this)
			catch (WollokProgramExceptionWrapper e) {
				var Object message = e.wollokMessage
				if (message === null)
					message = "NO MESSAGE"
				
				if (character !== null)
					character.scream("ERROR: " + message.toString())
				
				log.error(message, e)	
			} 
		}

		background.draw(window)
		components.forEach[it.draw(window)]
	}

	def pixelHeight() {
		return height * CELLZISE
	}

	def pixelWidth() {
		return width * CELLZISE
	}
	
	def clear() {
		components.clear()
		listeners.clear()
		character = null
	}

	def characterSay(String aText) {
		character.say(aText)
	}
	
	def getComponentsInPosition(Position p) {
		this.getComponents.filter [
			position == p
		]
	}

	// Getters & Setters

	def void addCharacter(VisualComponent character) {
		this.character = character
		addComponent(character)
		addListener(new ArrowListener(character))
	}

	def void addComponent(VisualComponent component) {
		components.add(component)
	}
	
	def void addComponents(Collection<VisualComponent> it) {
		components.addAll(it)
	}

	def void addListener(GameboardListener aListener){
		listeners.add(aListener)
	}
	
	def remove(VisualComponent component) {
		components.remove(component)
		listeners.removeIf[it.isObserving(component)]
	}
	
}
