package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

abstract class AbstractPosition {
	override public int hashCode() {
		val prime = 31
		val result = prime + x
		prime * result + y
	}
	
	override equals(Object obj) {
		if (obj == null) return false
		
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
	
	new() {}
	
	new(int x, int y) {
		this.x = x
		this.y = y
	}
}


class WPosition extends AbstractPosition {
	WollokObject position
	
	new(WollokObject wObject) {
		var method = wObject.allMethods.map[it.name].findFirst[this.isPositionGetter(it)]
		this.position = wObject.call(method)
	}
	
	def isPositionGetter(String methodName) {
		#["getPosicion", "getPosition", "posicion", "position"].contains(methodName)
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