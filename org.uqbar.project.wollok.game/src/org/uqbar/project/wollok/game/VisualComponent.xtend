package org.uqbar.project.wollok.game

import org.uqbar.project.wollok.interpreter.core.WollokObject
import java.util.Collection
import java.util.ArrayList
import java.util.List
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.Gdx
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.interpreter.core.ToStringBuilder
import org.eclipse.xtend.lib.annotations.Accessors

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

	def draw(SpriteBatch batch, BitmapFont font) {
		this.drawMe(batch);
		this.drawAttributesIfNecesary(batch, font);
		this.drawBallonIfNecesary(batch);
	}

	def drawBallonIfNecesary(SpriteBatch batch) {
		if (this.hasMessages())
			this.getCurrentMessage().draw(batch, this);
	}

	def drawAttributesIfNecesary(SpriteBatch batch, BitmapFont font) {
		var printableString = "";
		var glyphLayout = new GlyphLayout();
		
		for(String attr : this.attributes){
			printableString = printableString.concat(this.getShowableAttribute(attr).concat("\n"));
		}
		glyphLayout.reset();
		glyphLayout.setText(font, printableString, Color.WHITE, 220, 3, true);
		if (printableString != "" && this.isInMyZone())
			font.draw(batch, glyphLayout, this.getPosition().getXinPixels()-75, this.getPosition().getYinPixels());
	}

	def drawMe(SpriteBatch batch) {
		batch.draw(this.image.getTexture(), this.getPosition().getXinPixels(), this.getPosition().getYinPixels());
	}

	def isInMyZone(){
		var xMouse = Gdx.input.getX();
		var yMouse = Gdx.input.getY();
		var bottomX = this.getPosition().getXinPixels();
		var bottomY = Gameboard.getInstance().height() - this.getPosition().getYinPixels();
		var topX = bottomX + Gameboard.CELLZISE;
		var topY = bottomY - Gameboard.CELLZISE;
		return (xMouse > bottomX && xMouse < topX) && (yMouse < bottomY && yMouse > topY);
	}
	
	def getShowableAttribute(String attr) {
		var value = this.domainObject.getInstanceVariables().get(attr);
		
		return attr + ":" + new ToStringBuilder().smartToString(value);
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