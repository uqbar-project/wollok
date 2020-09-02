package org.uqbar.project.wollok.game.listeners

import java.util.ArrayList
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard

class ArrowListener extends GameboardListener {
	
	var listeners = new ArrayList<KeyboardListener>()
	
	new (VisualComponent character){
		listeners.add(new KeyboardListener("ArrowUp", [ character.up()]))
		listeners.add(new KeyboardListener("ArrowDown", [character.down()]))
		listeners.add(new KeyboardListener("ArrowLeft", [character.left()]))
		listeners.add(new KeyboardListener("ArrowRight", [character.right()]))
	}
	
	override notify(Gameboard gameboard) {
		listeners.forEach[notify(gameboard)]
	}
	
	override isObserving(VisualComponent component) {
		listeners.exists[isObserving(component)]
	}
	
}
