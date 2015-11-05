package org.uqbar.project.wollok.game

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.graphics.g2d.NinePatch
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import org.uqbar.project.wollok.game.gameboard.Gameboard

class Balloon {

	val static NinePatch patch = new NinePatch(new Texture(Gdx.files.internal("assets/speech.png")), 30, 60, 40, 50)
	val static colorNegro = Color.RED // Color.BLACK
	val width = 75
	val static textBitmap = new BitmapFont()
	var plusWidth = 0
	var glyphLayout = new GlyphLayout()

	def void draw(SpriteBatch batch, String text) {
		var newText = text
		if (text.length > 50)
			newText = text.substring(0,49) + "..."
		
		plusWidth = 0	
		glyphLayout.reset
		this.setText(newText, width)
		
		while(glyphLayout.height > 29){
			glyphLayout.reset
			plusWidth += 10
			this.setText(newText, width + plusWidth)
		}
		
		var character = Gameboard.getInstance.getCharacter()
		var	x = character.getPosition().getXinPixels() + 40
		var y = character.getPosition().getYinPixels() + 40
		patch.draw(batch, x, y, 100 + plusWidth, 85)
		
		textBitmap.draw(batch, glyphLayout, x + 10, y + 75);
	}
	
	private def setText(String text, int width) {
		glyphLayout.setText(textBitmap, text, colorNegro, width, 3, true)
	}
}
