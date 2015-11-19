package wollok.lib

import org.uqbar.project.wollok.game.helpers.Keyboard
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject

class KeysObject extends AbstractWollokDeclarativeNativeObject {

	var static keyboard = new Keyboard()

	def getKeyCode(String aKey) {
		keyboard.getKey(aKey)
	}
}
