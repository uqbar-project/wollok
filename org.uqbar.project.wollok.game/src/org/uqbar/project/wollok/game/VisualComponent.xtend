package org.uqbar.project.wollok.game

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.gameboard.Window
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.game.helpers.WollokConventionExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

@Accessors
class VisualComponent {
	public static val MESSAGE_MAX_LENGTH = 50
	public static val MESSAGE_TRIM_LENGTH = 45

	List<BalloonMessage> balloonMessages = newArrayList
	boolean showAttributes = false
	
	boolean hasText = false
	boolean hasTextColor = false
	boolean hasImage = false

	WollokObject wObject

	new(WollokObject object) {
		wObject = object
//		object.position
		hasText = wObject.understands(TEXT_CONVENTION)
		hasTextColor = wObject.understands(TEXT_COLOR_CONVENTION)
		hasImage = wObject.understands(IMAGE_CONVENTION)
	}
	
	def getAttributes() {
		wObject.printableVariables.filter[value !== null].map[key + ":" + value.toString].toList
	}

	def Image getImage() {
		hasImage ? new Image(wObject.image) : null
	}

	def Position getPosition() {
		objectPosition
	}

	def void setPosition(Position position) {
		wObject.position = objectPosition.copyFrom(position)
	}

	def getObjectPosition() {
		new WPosition(wObject.position)
	}

	def void draw(Window window) {
		window => [
			drawMe
			drawText
			drawAttributesIfNecesary
			drawBalloonIfNecesary
		]
	}

	def drawMe(Window window) {
		if(hasImage) {
			window.draw(image, position)
		}
	}
	
	def drawText(Window window) {
		if(hasText) {
			val text = wObject.call(TEXT_CONVENTION).wollokToJava(String) as String
			val color = hasTextColor ? Color.valueOf(wObject.call(TEXT_COLOR_CONVENTION).wollokToJava(String) as String) : DEFAULT_TEXT_COLOR  
		    window.writeText(text,  getPosition(), color)	  
		}	
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

	def isInMyZone() {
		val xMouse = Gdx.input.x
		val yMouse = Gdx.input.y
		val bottomX = position.xinPixels
		val bottomY = Gameboard.getInstance().pixelHeight - position.yinPixels
		val topX = bottomX + Gameboard.instance.cellsize
		val topY = bottomY - Gameboard.instance.cellsize
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
		if (position.y < Gameboard.instance.height - 1)
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
		if (position.x < Gameboard.instance.width - 1)
			setPosition(getPosition.right())
	}
}

class VisualComponentWithPosition extends VisualComponent {
	WollokObject wPosition
	

	new(WollokObject object, WollokObject position) {
		super(object)
		wPosition = position
	}
	
	override void setPosition(Position position) {
		wPosition = objectPosition.copyFrom(position)
	}
	
	override getObjectPosition() {
		new WPosition(wPosition)
	}
}