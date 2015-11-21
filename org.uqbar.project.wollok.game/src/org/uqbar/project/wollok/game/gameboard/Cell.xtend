package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.graphics.g2d.SpriteBatch
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
	
	def render(SpriteBatch batch) {
		batch.draw(image.getTexture(), this.width, this.height)
	}	
}