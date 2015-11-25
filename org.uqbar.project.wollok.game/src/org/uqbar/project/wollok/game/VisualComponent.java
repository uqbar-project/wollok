package org.uqbar.project.wollok.game;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.uqbar.project.wollok.game.Position;
import org.uqbar.project.wollok.game.gameboard.Gameboard;
import org.uqbar.project.wollok.interpreter.core.ToStringBuilder;
import org.uqbar.project.wollok.interpreter.core.WollokObject;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.GlyphLayout;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class VisualComponent {

	private Image image;
	private WollokObject domainObject;
	private Collection<String> attributes = new ArrayList<String>();
	private List<BalloonMessage> balloonMessages = new ArrayList<BalloonMessage>();
	
	public VisualComponent(WollokObject object) {
		this.domainObject = object;
		this.image = new WImage(object);
	}
	
	public VisualComponent(WollokObject object, String attr) {
		this(object);
		this.attributes.add(attr);
	}
	
	public VisualComponent(WollokObject object, Collection<Object> attrs) {
		this(object);
		for(Object attr : attrs){
			this.attributes.add(attr.toString());
		} 
	}
	
	public Position getPosition() {
		return new WPosition(WollokObject.class.cast(domainObject.call("getPosicion")));
	}

	public WollokObject getDomainObject() {
		return this.domainObject;
	}
	
	public void setMyDomainObject(WollokObject myDomainObject) {
		this.domainObject = myDomainObject;
	}
	
	public Object sendMessage(String message) {
		return this.domainObject.call(message);
	}
	
	public void say(String aText) {
		this.balloonMessages.add(new BalloonMessage(aText, Color.BLACK));
	}
	
	public void scream(String aText) {
		this.balloonMessages.add(new BalloonMessage(aText, Color.RED));
	}

	public void draw(SpriteBatch batch, BitmapFont font) {
		this.drawMe(batch);
		this.drawAttributesIfNecesary(batch, font);
		this.drawBallonIfNecesary(batch);
	}

	private void drawBallonIfNecesary(SpriteBatch batch) {
		if (this.hasMessages())
			this.getCurrentMessage().draw(batch, this);
	}

	private void drawAttributesIfNecesary(SpriteBatch batch, BitmapFont font) {
		String printableString = "";
		GlyphLayout glyphLayout = new GlyphLayout();
		
		for(String attr : this.attributes){
			printableString = printableString.concat(this.getShowableAttribute(attr).concat("\n"));
		}
		glyphLayout.reset();
		glyphLayout.setText(font, printableString, Color.WHITE, 220, 3, true);
		if (printableString != "" && this.isInMyZone())
			font.draw(batch, glyphLayout, this.getPosition().getXinPixels()-75, this.getPosition().getYinPixels());
	}

	private void drawMe(SpriteBatch batch) {
		batch.draw(this.image.getTexture(), this.getPosition().getXinPixels(), this.getPosition().getYinPixels());
	}

	private boolean isInMyZone(){
		int xMouse = Gdx.input.getX();
		int yMouse = Gdx.input.getY();
		int bottomX = this.getPosition().getXinPixels();
		int bottomY = Gameboard.getInstance().height() - this.getPosition().getYinPixels();
		int topX = bottomX + Gameboard.CELLZISE;
		int topY = bottomY - Gameboard.CELLZISE;
		return (xMouse > bottomX && xMouse < topX) && (yMouse < bottomY && yMouse > topY);
	}
	
	private String getShowableAttribute(String attr) {
		Object value = this.domainObject.getInstanceVariables().get(attr);
		
		return attr + ":" + value.toString(); //new ToStringBuilder().smartToString(value);
	}
	
	public boolean hasMessages() {
		List<BalloonMessage> textToDelete = new ArrayList<BalloonMessage>();
		for(int i = 0; i<this.balloonMessages.size();i++){
			if (this.balloonMessages.get(i).shouldRemove())
				textToDelete.add(balloonMessages.get(i));
		}
		this.balloonMessages.removeAll(textToDelete);
		return this.balloonMessages.size() > 0;
	}

	public BalloonMessage getCurrentMessage() {
		return this.balloonMessages.get(0);
	}
}
