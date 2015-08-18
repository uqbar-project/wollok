package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.ArrowListener

@Accessors
class GameConfiguration {
	var String gameboardTitle
	var int gameboardHeight
	var int gameboardWidth
	var String imageCharacter
	var String imageGround
	var boolean arrowListener
	
	def build (Gameboard aBoard){
		aBoard.createCells(imageGround)
		if (arrowListener)
			aBoard.addListener(new ArrowListener(aBoard))
		aBoard.getCharacterVisualcomponent().image = imageCharacter
	}
}