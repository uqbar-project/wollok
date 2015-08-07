package org.uqbar.project.wollok.game.listeners;

import com.badlogic.gdx.Input.Keys;

public class KeyboardListenerBuilder{
	private int key;
	private Runnable gameAction;
	
	public KeyboardListenerBuilder setLeftKey(){
		this.key = Keys.LEFT;
		return this;
	}
	
	public KeyboardListenerBuilder setRightKey(){
		this.key = Keys.RIGHT;
		return this;
	}
	
	public KeyboardListenerBuilder setUpKey(){
		this.key = Keys.UP;
		return this;
	}
	
	public KeyboardListenerBuilder setDownKey(){
		this.key = Keys.DOWN;
		return this;
	}
	
	public KeyboardListenerBuilder setAction(Runnable action){
		this.gameAction = action;
		return this;
	}
	
	public KeyboardListener build(){
		return new KeyboardListener(this.key, this.gameAction);
	}
}
