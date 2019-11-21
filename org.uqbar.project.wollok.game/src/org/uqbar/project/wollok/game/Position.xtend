package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

@Accessors
class WPosition extends Position {
	WollokObject wObject
	WollokInterpreter interpreter

	new(WollokObject position) {
		this.wObject = position
		this.interpreter = position.interpreter as WollokInterpreter
	}

	override getX() { wObject.getInt("x") }

	override getY() { wObject.getInt("y") }

	def getInt(WollokObject it, String methodName) { call(methodName).asInteger }
	
	def copyFrom(Position position) {
		buildPosition(position.x, position.y)
	}
	
	override createPosition(int newX, int newY) {
		wObject = this.buildPosition(newX, newY) 
		return new WPosition(wObject)
	}

	def buildPosition(int newX, int newY) {
		(interpreter.evaluator as WollokInterpreterEvaluator).newInstance(POSITION) => [
			setReference("x", newX.javaToWollok)
			setReference("y", newY.javaToWollok) 
		]
	}
	
}

abstract class Position {

	def abstract int getX()
	def abstract int getY()

	def getXinPixels() { x * Gameboard.instance.cellsize }

	def getYinPixels() { y * Gameboard.instance.cellsize }

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
		this.createPosition(x, y + 1)
	}

	def down() {
		this.createPosition(x, y - 1)
	}
	
	def left() {
		this.createPosition(x - 1, y)
	}
	
	def right() {
		this.createPosition(x + 1, y)
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
