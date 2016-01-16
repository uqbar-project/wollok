package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

abstract class AbstractPosition {
	override public int hashCode() {
		val prime = 31
		val result = prime + x
		prime * result + y
	}

	override equals(Object obj) {
		if(obj == null) return false

		var other = obj as AbstractPosition
		x == other.x && y == other.y
	}

	def getXinPixels() { x * Gameboard.CELLZISE }

	def getYinPixels() { y * Gameboard.CELLZISE }

	def void incX(int spaces) { x = x + spaces }

	def void incY(int spaces) { y = y + spaces }

	override toString() { getX + "@" + getY }

	def int getX()

	def void setX(int x)

	def int getY()

	def void setY(int y)
}

/**
 * 
 */
@Accessors
class Position extends AbstractPosition {
	private int x
	private int y

	new() {
	}

	new(int x, int y) {
		this.x = x
		this.y = y
	}
}

class WPosition extends AbstractPosition {
	public static val CONVENTIONS = #["posicion", "position"]

	WollokObject position

	new(WollokObject wObject) {
		position = wObject.getPosition()
	}

	def getPosition(WollokObject it) {
		var method = allMethods.map[it.name].findFirst[isPositionGetter]
		if (method != null)
			return call(method)

		var position = CONVENTIONS.map[c|instanceVariables.get(c)].filterNull.head
		if (position != null)
			return position
	}

	def isPositionGetter(String it) {
		CONVENTIONS.map[#[it, "get" + it.toFirstUpper]].flatten.toList.contains(it)
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
