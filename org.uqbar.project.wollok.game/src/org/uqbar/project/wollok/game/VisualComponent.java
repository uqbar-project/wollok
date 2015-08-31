package org.uqbar.project.wollok.game;

import org.uqbar.project.wollok.game.Position;
import org.uqbar.project.wollok.game.gameboard.Gameboard;
import org.uqbar.project.wollok.interpreter.core.WollokObject;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class VisualComponent {

	private Image image;
	private WollokObject domainObject;
	private String attribute;
	
	public VisualComponent(WollokObject object) {
		this.domainObject = object;
		this.image = new WImage(object);
	}
	
	public VisualComponent(WollokObject object, String attr) {
		this(object);
		this.attribute = attr;
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

	public void draw(SpriteBatch batch, BitmapFont font) {
		batch.draw(this.image.getTexture(), this.getPosition().getXinPixels(), this.getPosition().getYinPixels());

		if (this.attribute != null && this.isInMyZone())
			font.draw(batch, this.getShowableAttribute(), this.getPosition().getXinPixels(), this.getPosition().getYinPixels());
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
	
	private String getShowableAttribute() {
		String objectProperty = this.domainObject.getInstanceVariables().get(this.attribute).toString();
		return this.attribute + ":" + objectProperty;
	}
	
}
