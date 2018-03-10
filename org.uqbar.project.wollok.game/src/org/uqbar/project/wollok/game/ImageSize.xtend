package org.uqbar.project.wollok.game

import org.uqbar.project.wollok.game.gameboard.Gameboard

interface ImageSize {
	def int width(int textureWidth)
	def int height(int textureHeight)
}

class TextureSize implements ImageSize {
	override width(int textureWidth) { textureWidth	}	
	override height(int textureHeight) { textureHeight }	
}

class CellSize implements ImageSize {
	int size
	
	new (int size) { this.size = size }
	
	override width(int textureWidth) { size }	
	override height(int textureHeight) { size }
}

class GameSize implements ImageSize {
	Gameboard game
	
	new (Gameboard game) { this.game = game }
	
	override width(int textureWidth) { game.pixelWidth }	
	override height(int textureHeight) { game.pixelHeight }
}