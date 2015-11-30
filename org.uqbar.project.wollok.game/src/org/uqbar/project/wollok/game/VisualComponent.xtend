package org.uqbar.project.wollok.game

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import java.util.ArrayList
import java.util.Collection
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.gameboard.Window
import org.uqbar.project.wollok.interpreter.core.ToStringBuilder
import org.uqbar.project.wollok.interpreter.core.WollokObject

@Accessors
class VisualComponent {
	
	private Position position;
	private Image image;
	private WollokObject domainObject;
	private Collection<String> attributes = new ArrayList<String>();
	private List<BalloonMessage> balloonMessages = new ArrayList<BalloonMessage>();
	
	new (Position position, Image image) {
		this.position = position
		this.image = image
	}
	
	new (WollokObject object) {
		this.domainObject = object
		this.position = new WPosition(WollokObject.cast(domainObject.call("getPosicion")))
		this.image = new WImage(object)
	}
	
	new (WollokObject object, Collection<Object> attrs) {
		this(object);
		this.attributes.addAll(attrs.map[it.toString()])
	}
	
	def say(String aText) {
		this.balloonMessages.add(new BalloonMessage(aText, Color.BLACK));
	}
	
	def scream(String aText) {
		this.balloonMessages.add(new BalloonMessage(aText, Color.RED));
	}

	def void draw(Window window) {
		this.drawMe(window)
		this.drawAttributesIfNecesary(window)
		this.drawBallonIfNecesary(window)
	}

	def drawMe(Window window) {
		window.draw(this.image, this.position)
	}

	def drawAttributesIfNecesary(Window window) {		
		var printableString = this.attributes.map[ this.getShowableAttribute(it)].join("\n")
		if (printableString != "" && this.isInMyZone()) {
			window.writeAttributes(printableString, this.position, Color.WHITE)
		}
	}

	def drawBallonIfNecesary(Window window) {
		if (this.hasMessages())
			this.getCurrentMessage().draw(window, this);
	}

	def isInMyZone(){
		var xMouse = Gdx.input.getX();
		var yMouse = Gdx.input.getY();
		var bottomX = this.getPosition().getXinPixels();
		var bottomY = Gameboard.getInstance().pixelHeight() - this.getPosition().getYinPixels();
		var topX = bottomX + Gameboard.CELLZISE;
		var topY = bottomY - Gameboard.CELLZISE;
		return (xMouse > bottomX && xMouse < topX) && (yMouse < bottomY && yMouse > topY);
	}
	
	def getShowableAttribute(String attr) {
		var value = this.domainObject.getInstanceVariables().get(attr);
		
		return attr + ":" + value.toString
	}

	def hasMessages() {
		var textToDelete = new ArrayList<BalloonMessage>();
		for(var i = 0; i < this.balloonMessages.size(); i++){
			if (this.balloonMessages.get(i).shouldRemove())
				textToDelete.add(balloonMessages.get(i));
		}
		this.balloonMessages.removeAll(textToDelete);
		return this.balloonMessages.size() > 0;
	}

	def getCurrentMessage() {
		return this.balloonMessages.get(0);
	}
}