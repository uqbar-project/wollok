package org.uqbar.project.wollok.game

import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Window
import com.badlogic.gdx.graphics.Color

@Accessors
class BalloonMessage {
	var static timeToLive = 2000
	
	var String text
	var Color color
	var long timestamp = 0
	
	new (String aText, Color aColor) {
		text = aText
		color = aColor
	}
	
	def boolean shouldRemove() {
		timestamp != 0 && new Date().time - timestamp > timeToLive   
	}
	
	def void draw(Window window, VisualComponent character) {
		if (timestamp == 0)
			timestamp = new Date().time
		
		window.drawBalloon(this.text, character.position, this.color)
	}
}