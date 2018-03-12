package org.uqbar.project.wollok.game

import org.uqbar.project.wollok.game.gameboard.Gameboard

interface ImageSize {
	def int width(int originalWidth)
	def int height(int originalHeight)
}

class TextureSize implements ImageSize {
	override width(int originalWidth) { originalWidth }	
	override height(int originalHeight) { originalHeight }	
}

class CellSize implements ImageSize {
	int size
	
	new (int size) { this.size = size }
	
	override width(int originalWidth) { size }	
	override height(int originalHeight) { size }
}

class GameSize implements ImageSize {
	Gameboard game
	
	new (Gameboard game) { this.game = game }
	
	override width(int originalWidth) { game.pixelWidth }	
	override height(int originalHeight) { game.pixelHeight }
}