package org.uqbar.project.wollok.game.listeners

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.helpers.Keyboard

import static extension org.uqbar.project.wollok.game.listeners.WollokKeycodeToLibGDX.*

@Accessors(PUBLIC_GETTER)
class KeyboardListener extends GameboardListener {

	var keyboard = Keyboard.instance
	String keyCode
	Runnable gameAction

	new(String keyCode, Runnable gameAction) {
		this.keyCode = keyCode
		this.gameAction = gameAction
	}

	override notify(Gameboard gameboard) {
		if (keyCode.toKeys.exists[keyboard.isKeyPressed(it)])
			gameAction.run()
	}

	override isObserving(VisualComponent component) {
		false
	}
}
