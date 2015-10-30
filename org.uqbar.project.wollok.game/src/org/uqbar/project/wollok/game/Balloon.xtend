package org.uqbar.project.wollok.game

import com.badlogic.gdx.graphics.g2d.NinePatch
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.Gdx
import org.uqbar.project.wollok.game.gameboard.Gameboard
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.graphics.Color

class Balloon {

	NinePatch patch

	new() {
		super()
		patch = new NinePatch(new Texture(Gdx.files.internal("assets/speech.png")), 30, 60, 40, 50)
	}

	def void draw(SpriteBatch batch, String text) {
		var newText = text
		if (text.length > 50)
			newText = text.substring(0,49) + "..."
			
		var textBitmap = new BitmapFont()
		var glyphLayout = new GlyphLayout()
		val width = 75
		var plusWidth = 0 
		glyphLayout.setText(textBitmap,newText,new Color(0,0,0,100),width,3,true)
		while(glyphLayout.height > 29){
			glyphLayout.reset
			plusWidth += 10
			glyphLayout.setText(textBitmap,newText,new Color(0,0,0,100),width + plusWidth,3,true)
		}
		
		var character = Gameboard.getInstance.getCharacter()
		var	x = character.getPosition().getXinPixels() + 40
		var y = character.getPosition().getYinPixels() + 40
		patch.draw(batch, x, y, 100 + plusWidth, 85)
		
		textBitmap.setColor(0, 0, 0, 100)
		textBitmap.draw(batch, glyphLayout, x + 10, y + 75);
	}
}
