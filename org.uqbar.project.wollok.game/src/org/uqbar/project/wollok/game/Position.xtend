package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard

abstract class Position {

	def abstract int getX()
	def abstract void setX(int x)
	def abstract int getY()
	def abstract void setY(int y)

	def getXinPixels() { x * Gameboard.CELLZISE }

	def getYinPixels() { y * Gameboard.CELLZISE }

	def incX(int spaces) { 
		x = x + spaces
		if (x < 0) x = 0
		if (x >= Gameboard.instance.width) x = Gameboard.instance.width - 1
	}

	def incY(int spaces) { 
		y = y + spaces
		if (y < 0) y = 0
		if (y >= Gameboard.instance.height) y = Gameboard.instance.height - 1
	}

	override public int hashCode() {
		val prime = 31
		val result = prime + x
		prime * result + y
	}

	override equals(Object obj) {
		if(obj === null) return false

		val other = obj as Position
		x == other.x && y == other.y
	}
	
	override toString() { getX + "@" + getY }	
}

@Accessors
class WGPosition extends Position {
	private int x
	private int y

	new() { }

	new(int x, int y) {
		this.x = x
		this.y = y
	}
}
