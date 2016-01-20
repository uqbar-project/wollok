package wollok.lib

import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

@Accessors
class WPosition extends Position {
	WollokObject wObject

	new(WollokObject position) {
		wObject = position
	}

	override getX() { wObject.getInt("getX") }

	override getY() { wObject.getInt("getY") }

	override setX(int num) { wObject.setInt("setX", num) }

	override setY(int num) { wObject.setInt("setY", num) }


	def getInt(WollokObject it, String methodName) { call(methodName).asInteger }
	def setInt(WollokObject it, String methodName, Integer num) { call(methodName, num.javaToWollok) }
	
	def void copyFrom(Position position) {
		setX(position.x)
		setY(position.y)
	}
}
