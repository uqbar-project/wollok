package org.uqbar.project.wollok.game.listeners

import com.badlogic.gdx.Input.Keys;

class KeyboardListenerBuilder {
	
	int key;
	Runnable gameAction;
	
	def setLeftKey(){
		this.key = Keys.LEFT;
		return this;
	}
	
	def setRightKey(){
		this.key = Keys.RIGHT;
		return this;
	}
	
	def setUpKey(){
		this.key = Keys.UP;
		return this;
	}
	
	def setDownKey(){
		this.key = Keys.DOWN;
		return this;
	}
	
	def setAction(Runnable action){
		this.gameAction = action;
		return this;
	}
	
	def KeyboardListener build(){
		return new KeyboardListener(this.key, this.gameAction);
	}	
}