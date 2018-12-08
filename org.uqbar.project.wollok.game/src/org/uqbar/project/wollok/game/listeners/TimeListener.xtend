package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

class TimeListener extends GameboardListener {

	long timeSinceLastRun = System.currentTimeMillis
	String name	
	int millisecondsEvery
	() => Object block
	
	new(String name, int millisecondsEvery, ()=>Object block) {
		this.name = name
		this.millisecondsEvery = millisecondsEvery
		this.block = block
	}
	
	override notify(Gameboard gameboard) {
		if (shouldRun) {
			try {
				block.apply
			} catch (WollokProgramExceptionWrapper e) {
				gameboard.errorReporter?.scream(e.wollokMessage)
			}
			timeSinceLastRun = System.currentTimeMillis
		}
	}
	
	override isObserving(VisualComponent component) { false }
	
	override name() { name }
	
	def boolean shouldRun() {
		System.currentTimeMillis - timeSinceLastRun > millisecondsEvery
	}
	
	
}