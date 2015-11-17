package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.gameboard.Gameboard

class KeyboardListener implements GameboardListener {
	
	int key;
	Runnable gameAction;

	new (int key, Runnable gameAction) {
		this.key = key;
		this.gameAction = gameAction;
		
	}

	override notify(Gameboard gameboard) {
		if (gameboard.isKeyPressed(this.key))
			gameAction.run();
	}
}