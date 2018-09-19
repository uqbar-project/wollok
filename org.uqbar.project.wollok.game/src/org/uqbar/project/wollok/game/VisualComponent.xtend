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
	public static val MESSAGE_MAX_LENGTH = 50
	public static val MESSAGE_TRIM_LENGTH = 45
	
	List<BalloonMessage> balloonMessages = newArrayList
	boolean showAttributes = true
	
	def abstract List<String> getAttributes()
	def abstract Image getImage()
	def abstract Position getPosition()
	def abstract void setPosition(Position image)

	def void draw(Window window) {
		window => [
			drawMe
			drawAttributesIfNecesary
			drawBalloonIfNecesary
		]
	}

	def drawMe(Window window) {
		window.draw(image, position)
	}

	def drawAttributesIfNecesary(Window window) {
		if (showAttributes && inMyZone) {
			val printableString = getAttributes.join(System.lineSeparator)
			if (printableString != "") {
				window.writeAttributes(printableString, position, Color.WHITE)
			}
		}
	}

	def drawBalloonIfNecesary(Window window) {
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
		if (message.length > MESSAGE_MAX_LENGTH) {
			val beginning = message.substring(0, MESSAGE_TRIM_LENGTH) + ".."
			val end = ".." + message.substring(MESSAGE_TRIM_LENGTH, message.length)
			this.addMessage(beginning, color)
			this.addMessage(end, color)
			return 
		}
		
		balloonMessages.add(new BalloonMessage(message, color))
	}

	def isInMyZone(){
		val xMouse = Gdx.input.x
		val yMouse = Gdx.input.y
		val bottomX = position.xinPixels
		val bottomY = Gameboard.getInstance().pixelHeight - position.yinPixels
		val topX = bottomX + Gameboard.CELLZISE
		val topY = bottomY - Gameboard.CELLZISE
		return (xMouse > bottomX && xMouse < topX) && (yMouse < bottomY && yMouse > topY)
	}
	

	def hasMessages() {
		val textToDelete = new ArrayList<BalloonMessage>()
		for (var i = 0; i < this.balloonMessages.size; i++) {
			if (balloonMessages.get(i).shouldRemove)
				textToDelete.add(balloonMessages.get(i))
		}
		balloonMessages.removeAll(textToDelete)
		balloonMessages.size > 0
	}

	def getCurrentMessage() {
		balloonMessages.get(0)
	}
	
	def hideAttributes() { showAttributes = false }
	def showAttributes() { showAttributes = true }
	
	def void up() {
		if (position.y < Gameboard.instance.height)
			setPosition(getPosition.up())
	}
	
	def void down() {
		if (position.y > 0)
			setPosition(getPosition.down())
	}
	
	def void left() {
		if (position.x > 0)
			setPosition(getPosition.left())
	}
	
	def void right() {
		if (position.x < Gameboard.instance.width)
			setPosition(getPosition.right())
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