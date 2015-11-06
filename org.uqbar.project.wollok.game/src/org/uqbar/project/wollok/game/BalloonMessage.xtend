package org.uqbar.project.wollok.game

import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.NinePatch
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color

@Accessors
class BalloonMessage {
	val static patch = new NinePatch(new Texture(Gdx.files.internal("assets/speech.png")), 30, 60, 40, 50)
	val static glyphLayout = new GlyphLayout()
	val static textBitmap = new BitmapFont()
	val static baseWidth = 75
	var static timeToLive = 2000
	
	var String text
	var Color color
	var long timestamp = 0
	
	new (String aText, Color aColor){
		text = aText
		color = aColor
	}
	
	def boolean shouldRemove(){
		return timestamp != 0 && new Date().time - timestamp > timeToLive   
	}
	
	def draw(SpriteBatch batch, VisualComponent character) {
		if (timestamp == 0)
			timestamp = new Date().time
			
		var newText = text
		if (text.length > 50)
			newText = text.substring(0,49) + "..."
		
		var plusWidth = 0	
		glyphLayout.reset
		this.setText(newText, baseWidth)
		
		while(glyphLayout.height > 29){
			glyphLayout.reset
			plusWidth += 10
			this.setText(newText, baseWidth + plusWidth)
		}
		
		var	x = character.getPosition().getXinPixels() + 40
		var y = character.getPosition().getYinPixels() + 40
		patch.draw(batch, x, y, 100 + plusWidth, 85)
		
		textBitmap.draw(batch, glyphLayout, x + 10, y + 75);
	}
		
	private def setText(String text, int width) {
		glyphLayout.setText(textBitmap, text, color, width, 3, true)
	}
}