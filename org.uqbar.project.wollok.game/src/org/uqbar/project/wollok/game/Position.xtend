package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard

abstract class Position {

	def abstract int getX()
	def abstract int getY()

	def getXinPixels() { x * Gameboard.CELLZISE }

	def getYinPixels() { y * Gameboard.CELLZISE }

	def adjustX(int newX) {
		if (newX < 0) return 0
		if (newX >= Gameboard.instance.width) return Gameboard.instance.width - 1
		return newX
	}

	def adjustY(int newY) { 
		if (newY < 0) return 0
		if (newY >= Gameboard.instance.height) return Gameboard.instance.height - 1
		return newY
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

	def up() {
		this.createPosition(x, adjustY(y + 1))
	}

	def down() {
		this.createPosition(x, adjustY(y - 1))
	}
	
	def left() {
		this.createPosition(adjustX(x - 1), y)
	}
	
	def right() {
		this.createPosition(adjustX(x + 1), y)
	}
	
	/** Factory method */
	def Position createPosition(int newX, int newY)

}

@Accessors
class WGPosition extends Position {
	private int x = 0
	private int y = 0

	new() { }

	new(int x, int y) {
		this.x = x
		this.y = y
	}
	
	override createPosition(int newX, int newY) {
		return new WGPosition(newX, newY)
	}

}
