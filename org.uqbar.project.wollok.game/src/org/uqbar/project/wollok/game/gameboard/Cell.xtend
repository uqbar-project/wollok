package org.uqbar.project.wollok.game.gameboard

import org.uqbar.project.wollok.game.Image

class Cell {
	var int width
	var int height
	var Image image

	new (int widthSize, int heghtSize, String image) {
		this.width = widthSize
		this.height = heghtSize
		this.image = new Image(image)
	}
	
	def render(Window window) {
		window.drawIn(image, width, height)
	}	
}