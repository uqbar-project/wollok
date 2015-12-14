package org.uqbar.project.wollok.game

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import java.util.ArrayList
import java.util.Collection
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.gameboard.Window
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * 
 */
@Accessors
class VisualComponent {
	AbstractPosition position
	Image image
	WollokObject domainObject
	Collection<String> attributes = newArrayList
	List<BalloonMessage> balloonMessages = newArrayList
	
	new (AbstractPosition position, Image image) {
		this.position = position
		this.image = image
	}
	
	new (WollokObject object) {
		domainObject = object
		position = new WPosition(WollokObject.cast(domainObject.call("getPosicion")))
		image = new WImage(object)
	}
	
	new (WollokObject object, Collection<Object> attrs) {
		this(object);
		attributes.addAll(attrs.map[toString])
	}
	
	def say(String aText) {
		balloonMessages.add(new BalloonMessage(aText, Color.BLACK))
	}
	
	def scream(String aText) {
		balloonMessages.add(new BalloonMessage(aText, Color.RED))
	}

	def void draw(Window window) {
		window => [
			drawMe
			drawAttributesIfNecesary
			drawBallonIfNecesary
		]
	}

	def drawMe(Window window) {
		window.draw(image, position)
	}

	def drawAttributesIfNecesary(Window window) {		
		var printableString = this.attributes.map[ showableAttribute ].join("\n")
		if (printableString != "" && inMyZone) {
			window.writeAttributes(printableString, position, Color.WHITE)
		}
	}

	def drawBallonIfNecesary(Window window) {
		if (hasMessages)
			currentMessage.draw(window, this)
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
	
	def getShowableAttribute(String attr) {
		var value = domainObject.instanceVariables.get(attr)
		attr + ":" + value.toString
	}

	def hasMessages() {
		var textToDelete = new ArrayList<BalloonMessage>();
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