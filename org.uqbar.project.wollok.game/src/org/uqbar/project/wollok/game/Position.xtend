package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard

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


