package org.uqbar.project.wollok.game.gameboard

import org.eclipse.xtend.lib.annotations.Accessors
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.Gdx

@Accessors
class Cell {
	var int width;
	var int height;
	var String element;
	var Texture texture;

	new (int widthSize,int heghtSize, String groundImage) {
		this.width = widthSize;
		this.height = heghtSize;
		this.element = groundImage;
	}
	
	
	def Texture getTexture(){
		if (this.texture == null)
			return this.texture = new Texture(Gdx.files.internal(this.element))
		return this.texture
	}
}