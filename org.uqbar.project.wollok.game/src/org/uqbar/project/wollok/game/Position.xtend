package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard

@Accessors
class Position {
	private int x
	private int y

	override public int hashCode() {
		val prime = 31
		val result = prime + x
		prime * result + y
	}

	override equals(Object obj) {
		if(obj == null) return false

		var other = obj as Position
		x == other.x && y == other.y
	}

	new() { }

	new(int x, int y) {
		this.x = x
		this.y = y
	}

	def getXinPixels() { x * Gameboard.CELLZISE }

	def getYinPixels() { y * Gameboard.CELLZISE }

	def incX(int spaces) { x = x + spaces }

	def incY(int spaces) { y = y + spaces }

	override toString() { getX + "@" + getY }
}
