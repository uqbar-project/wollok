package org.uqbar.project.wollok.game

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.gameboard.Window

/**
 * 
 */
@Accessors
abstract class VisualComponent {
	List<BalloonMessage> balloonMessages = newArrayList
	
	def abstract List<String> getAttributes()
	def abstract Image getImage()
	def abstract Position getPosition()
	def abstract void setPosition(Position image)

	def void draw(Window window) {
		window => [
			drawMe
			drawAttributesIfNecesary
			drawBaloonIfNecesary
		]
	}

	def drawMe(Window window) {
		window.draw(image, position)
	}

	def drawAttributesIfNecesary(Window window) {
		if (inMyZone) {
			val printableString = getAttributes.join(System.lineSeparator)
			if (printableString != "") {
				window.writeAttributes(printableString, position, Color.WHITE)
			}
		}
	}

	def drawBaloonIfNecesary(Window window) {
		if (hasMessages)
			currentMessage.draw(window, this)
	}

	def say(String aText) {
		addMessage(aText, Color.BLACK)
	}
	
	def scream(String aText) {
		addMessage(aText, Color.RED)
	}
	
	def void addMessage(String message, Color color) {
		if (message.length > 50) {
			var beginning = message.substring(0, 45) + ".."
			var end = ".." + message.substring(46, message.length)
			this.addMessage(beginning, color)
			this.addMessage(end, color)
			return 
		}
		
		balloonMessages.add(new BalloonMessage(message, color))
	}

	def isInMyZone(){
		var xMouse = Gdx.input.x
		var yMouse = Gdx.input.y
		var bottomX = position.xinPixels
		var bottomY = Gameboard.getInstance().pixelHeight - position.yinPixels
		var topX = bottomX + Gameboard.CELLZISE
		var topY = bottomY - Gameboard.CELLZISE
		return (xMouse > bottomX && xMouse < topX) && (yMouse < bottomY && yMouse > topY)
	}
	

	def hasMessages() {
		var textToDelete = new ArrayList<BalloonMessage>()
		for (var i = 0; i < this.balloonMessages.size; i++) {
			if (balloonMessages.get(i).shouldRemove)
				textToDelete.add(balloonMessages.get(i))
		}
		balloonMessages.removeAll(textToDelete)
		return balloonMessages.size > 0
	}

	def getCurrentMessage() {
		balloonMessages.get(0)
	}
}

@Accessors
class WGVisualComponent extends VisualComponent {
	Position position
	Image image
	List<String> attributes
	
	new (Position position, Image image) {
		this.position = position
		this.image = image
	}
}