package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard

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
			} finally {				
				gameboard.afterRun
			}
		}
	}
	
	def void afterRun(Gameboard gameboard) {
		timeSinceLastRun = System.currentTimeMillis
	}
	
	override isObserving(VisualComponent component) { false }
	
	override name() { name }
	
	def boolean shouldRun() {
		System.currentTimeMillis - timeSinceLastRun > millisecondsEvery
	}

}

class ScheduleListener extends TimeListener {
	
	new(int milliseconds, ()=>Object block) {
		super("", milliseconds, block)
	}
	
	override afterRun(Gameboard gameboard) {
		gameboard.removeListener(this)
	}
	
}