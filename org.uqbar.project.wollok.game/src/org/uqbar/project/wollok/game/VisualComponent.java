package org.uqbar.project.wollok.game;

import org.uqbar.project.wollok.game.Position;
import org.uqbar.project.wollok.interpreter.core.WollokObject;

import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class VisualComponent {

	private Position position;
	private Image image;
	private WollokObject domainObject;
	private String attribute;
	
	public VisualComponent(WollokObject object) {
		this.domainObject = object;
		this.image = new WImage(object);
		this.position = new WPosition(object);
	}
	
	public VisualComponent(WollokObject object, String attr) {
		this(object);
		this.attribute = attr;
	}
	
	public Position getPosition() {
		return position;
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

		if (this.attribute != null)
			font.draw(batch, this.getShowableAttribute(), this.getPosition().getXinPixels(), this.getPosition().getYinPixels());
	}

	private String getShowableAttribute() {
		String objectProperty = this.sendMessage(this.attribute).toString();
		return this.attribute + ":" + objectProperty;
	}
	
}
