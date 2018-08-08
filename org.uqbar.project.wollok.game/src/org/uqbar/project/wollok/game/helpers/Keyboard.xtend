package org.uqbar.project.wollok.game.helpers

import com.badlogic.gdx.Input.Keys
import com.badlogic.gdx.Gdx

class Keyboard {
	
	var static Keyboard instance
	
	def static getInstance() {
		if (instance === null)
			instance = new Keyboard()
			
		instance
	}
	
	// For testing TODO: use DI
	def static setInstance(Keyboard keyboard) {
		instance = keyboard
	}
	
	def boolean isKeyPressed(int key) {
		return Gdx.input.isKeyJustPressed(key)
	}
	
	def getKey(String aKey) {
		try {
			return typeof(Keys).getDeclaredField(aKey.toUpperCase).get(typeof(Integer)) as Integer;
		} catch (Exception e) {
			// TODO: i18n
			throw new RuntimeException("No se encuentra el caracter " + aKey + ".")
		}
	}
}