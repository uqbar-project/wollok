package org.uqbar.project.wollok.game.helpers

import com.badlogic.gdx.Input.Keys
import com.badlogic.gdx.Gdx

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Keyboard {
	
	public static Keyboard instance
	
	def static getInstance() {
		if (instance == null)
			instance = new Keyboard()
			
		instance
	}
	
	def isKeyPressed(int key) {
		return Gdx.input.isKeyJustPressed(key);
	}
	
	def getKey(String aKey) {
		try {
			return typeof(Keys).getDeclaredField(aKey.toUpperCase).get(typeof(Integer)) as Integer;
		} catch (Exception e) {
			throw new RuntimeException("No se encuentra el caracter " + aKey + ".")
		}
	}
}