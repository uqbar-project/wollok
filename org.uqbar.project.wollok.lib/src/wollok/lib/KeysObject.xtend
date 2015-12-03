package wollok.lib

import org.uqbar.project.wollok.game.helpers.Keyboard

/**
 * @author ?
 */
class KeysObject {

	var static keyboard = new Keyboard()

	def getKeyCode(String aKey) {
		keyboard.getKey(aKey)
	}
}
