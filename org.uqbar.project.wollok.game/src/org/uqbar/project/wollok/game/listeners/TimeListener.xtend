package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

class TimeListener implements GameboardListener {

	long timeSinceLastRun = 0	
	int millisecondsEvery
	() => Object block
	
	new(int millisecondsEvery, ()=>Object block) {
		this.millisecondsEvery = millisecondsEvery
		this.block = block
	}
	
	override notify(Gameboard gameboard) {
		if (shouldRun) {
			try {
				block.apply
			} catch (WollokProgramExceptionWrapper e) {
				gameboard.somebody?.scream(e.wollokMessage)
			}
			timeSinceLastRun = System.currentTimeMillis
		}
	}
	
	override isObserving(VisualComponent component) { 
		false
	}
	
	def boolean shouldRun() {
		System.currentTimeMillis - timeSinceLastRun > millisecondsEvery
	}
	
}