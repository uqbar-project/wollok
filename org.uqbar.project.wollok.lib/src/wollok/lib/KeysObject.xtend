package wollok.lib

import com.badlogic.gdx.Input.Keys
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject

class KeysObject extends AbstractWollokDeclarativeNativeObject {

	def getKeyCode(String aKey) {
		try {
			return typeof(Keys).getDeclaredField(aKey.toUpperCase).get(typeof(Integer));
		} catch (Exception e) {
			throw new RuntimeException("No se encuentra el caracter " + aKey + ".")
		}
	}
}
