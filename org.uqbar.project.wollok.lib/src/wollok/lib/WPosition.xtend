package wollok.lib

import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class WPosition extends Position {
	()=>WollokObject positionGetter

	new(()=>WollokObject positionGetter) {
		this.positionGetter = positionGetter
	}

	new(WollokObject position) {
		this[position]
	}

	override getX() { position.getInt("getX") }

	override getY() { position.getInt("getY") }

	override setX(int num) { position.setInt("setX", num) }

	override setY(int num) { position.setInt("setY", num) }


	def getInt(WollokObject it, String methodName) { call(methodName).asInteger }
	def setInt(WollokObject it, String methodName, Integer num) { call(methodName, num.javaToWollok) }
	
	def getPosition() { positionGetter.apply }
	
	def void copyFrom(Position position) {
		setX(position.x)
		setY(position.y)
	}
}
