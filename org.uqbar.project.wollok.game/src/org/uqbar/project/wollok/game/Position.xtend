package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.interpreter.core.WollokObject
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

@Accessors
class Position {
	private int x;
	private int y;
	
	new() {}
	
	new(int x, int y) {
		this.x = x
		this.y = y
	}
	
	override public int hashCode() {
		val prime = 31
		val result = prime + x
		prime * result + y
	}
	
	override public boolean equals(Object obj) {
		if (obj == null) return false
		
		var Position other = obj as Position
		x == other.x && y == other.y 
	}
	
	def public int getXinPixels(){
		x * Gameboard.CELLZISE
	}

	def public int getYinPixels(){
		y * Gameboard.CELLZISE
	}	
	
	def public void incX(int spaces) {
		x = x + spaces
	}
	
	def public void incY(int spaces) {
		y = y + spaces
	}		
}


class WPosition extends Position {
	WollokObject position
	
	new(WollokObject wObject) {
		this.position = wObject
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