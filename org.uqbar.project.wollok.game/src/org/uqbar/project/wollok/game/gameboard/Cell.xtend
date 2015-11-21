package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.Texture.TextureFilter

class Cell {
	var int width
	var int height
	var String image
	var Texture texture

	new (int widthSize, int heghtSize, String image) {
		this.width = widthSize
		this.height = heghtSize
		this.image = image
	}
	
	def getTexture() {
		if (texture == null)
			this.texture = new Texture(Gdx.files.internal(this.image))
		texture.setFilter(TextureFilter.Linear, TextureFilter.Linear)
		texture 
	}
	
	def render(SpriteBatch batch, BitmapFont font) {
		batch.draw(this.getTexture(), this.width, this.height)
	}	
}