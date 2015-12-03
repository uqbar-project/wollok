package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard

@Accessors
class GameConfiguration {
	var String gameboardTitle
	var int gameboardHeight
	var int gameboardWidth
	var String imageGround
	
	def void configure(Gameboard gameboard) {
		gameboard.title = this.gameboardTitle
		gameboard.height = this.gameboardHeight
		gameboard.width = this.gameboardWidth
		gameboard.createCells(this.imageGround)
	}
	
}