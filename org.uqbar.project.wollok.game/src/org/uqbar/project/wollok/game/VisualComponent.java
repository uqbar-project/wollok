package org.uqbar.project.wollok.game;

import org.uqbar.project.wollok.game.Position;

public class VisualComponent {

	private Position position;
	private String image;
	private Object domainObject;
	
	public VisualComponent() { }
	
	public VisualComponent(Object object, String image, Position position) {
		this.domainObject = object;
		this.image = image;
		this.position = position;
	}
	
	public Position getMyPosition() {
		return position;
	}
	public void setMyPosition(Position myPosition) {
		this.position = myPosition;
	}
	public String getImage() {
		return image;
	}
	public void setImage(String image) {
		this.image = image;
	}
	public Object getMyDomainObject() {
		return domainObject;
	}
	public void setMyDomainObject(Object myDomainObject) {
		this.domainObject = myDomainObject;
	}
	
	
}
