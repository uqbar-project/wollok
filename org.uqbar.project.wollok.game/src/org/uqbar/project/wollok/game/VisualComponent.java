package org.uqbar.project.wollok.game;

import org.uqbar.project.wollok.game.Position;
import org.uqbar.project.wollok.interpreter.core.WollokObject;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.Texture.TextureFilter;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class VisualComponent {

	private Position position;
	private String image;
	// En realidad es un WollokObject pero lo debo tratar como object generalmente...WTF!
	private Object domainObject;
	private Texture texture;
	private String attribute;
	
	public VisualComponent() { }
	
	public VisualComponent(WollokObject object, String image, Position position) {
		this.domainObject = object;
		this.image = image;
		this.position = position;
	}
	
	public VisualComponent(WollokObject object, String image, Position position, String attr) {
		this(object, image, position);
		this.attribute = attr;
	}
	
	public Position getMyPosition() {
		return position;
	}
	public Object getMyDomainObject() {
		return domainObject;
	}
	public void setMyDomainObject(Object myDomainObject) {
		this.domainObject = myDomainObject;
	}
	
	public Texture getTexture(){
		if(this.texture == null)
			this.texture = new Texture(Gdx.files.internal(image));
			this.texture.setFilter(TextureFilter.Linear, TextureFilter.Linear);
		return this.texture;
	}
	
	public Object sendMessage(String message) {
		return WollokObject.class.cast(this.domainObject).call(message);
	}

	public void draw(SpriteBatch batch, BitmapFont font) {
		batch.draw(this.getTexture(), this.getMyPosition().getXinPixels(), this.getMyPosition().getYinPixels());

		if (this.attribute != null)
			font.draw(batch, this.getShowableAttribute(), this.getMyPosition().getXinPixels(), this.getMyPosition().getYinPixels());
	}

	private String getShowableAttribute() {
		String objectProperty = this.sendMessage(this.attribute).toString();
		return this.attribute + ":" + objectProperty;
	}
	
}
