package wollok.lib

import org.uqbar.project.wollok.game.AbstractPosition
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class WPosition extends AbstractPosition {
	WollokObject position

	new(WollokObject pos) {
		position = pos
	}

	override getX() { position.getInt("getX") }

	override getY() { position.getInt("getY") }

	def getInt(WollokObject it, String methodName) { call(methodName).wollokToJava(Integer) as Integer }

	override setX(int num) {
		position.call("setX", num.javaToWollok)
	}

	override setY(int num) {
		position.call("setY", num.javaToWollok)
	}

}
