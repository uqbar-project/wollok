package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.helpers.Keyboard
import org.uqbar.project.wollok.game.VisualComponent

class KeyboardListener implements GameboardListener {

	var keyboard = Keyboard.instance
	int key
	Runnable gameAction

	new(int key, Runnable gameAction) {
		this.key = key
		this.gameAction = gameAction
	}

	override notify(Gameboard gameboard) {
		if (keyboard.isKeyPressed(this.key))
			gameAction.run()
	}

	override isObserving(VisualComponent component) {
		false
	}
}
