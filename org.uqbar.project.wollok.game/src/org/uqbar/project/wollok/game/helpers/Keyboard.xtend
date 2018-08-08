package org.uqbar.project.wollok.game.helpers

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.Input.Keys
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.game.Messages

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
			throw new RuntimeException(NLS.bind(Messages.WollokGame_CharacterKeyNotFound, aKey))
		}
	}
}