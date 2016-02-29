package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.VisualComponent

interface GameboardListener {
	
	def void notify(Gameboard gameboard)
	
	def boolean isObserving(VisualComponent component)
	
}