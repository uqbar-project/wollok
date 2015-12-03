package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.gameboard.Gameboard

interface GameboardListener {
	
	def void notify(Gameboard gameboard)
	
}