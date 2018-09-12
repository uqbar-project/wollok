package org.uqbar.project.wollok.game.listeners

import com.badlogic.gdx.Input.Keys

import java.util.ArrayList

import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.VisualComponent

class ArrowListener extends GameboardListener {
	
	var listeners = new ArrayList<KeyboardListener>()
	
	new (VisualComponent character){
		listeners.add(new KeyboardListener(Keys.UP, [character.position.incY(1)]))
		listeners.add(new KeyboardListener(Keys.DOWN, [character.position.incY(-1)]))
		listeners.add(new KeyboardListener(Keys.LEFT, [character.position.incX(-1)]))
		listeners.add(new KeyboardListener(Keys.RIGHT, [character.position.incX(1)]))
	}
	
	override notify(Gameboard gameboard) {
		listeners.forEach[notify(gameboard)]
	}
	
	override isObserving(VisualComponent component) {
		listeners.exists[isObserving(component)]
	}
	
}
