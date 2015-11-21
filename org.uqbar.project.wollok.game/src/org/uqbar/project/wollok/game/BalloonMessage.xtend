package org.uqbar.project.wollok.game

import java.util.Date
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.NinePatch
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Window

@Accessors
class BalloonMessage {
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
	
	def draw(Window window, VisualComponent character) {
		if (timestamp == 0)
			timestamp = new Date().time
		
		window.drawBallon(this.text, character.position, this.color)
	}
}