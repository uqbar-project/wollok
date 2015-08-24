package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard

@Accessors
class Position {
	private int x;
	private int y;
	
	new() {}
	
	new(int x, int y) {
		this.x = x;
		this.y = y;
	}
	
	
	override public int hashCode() {
		val int prime = 31;
		var int result = 1;
		result = prime * result + this.getX();
		result = prime * result + this.getY();
		return result;
	}
	
	override public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		var Position other = obj as Position;
		if (this.getX() != other.getX())
			return false;
		if (this.getY() != other.getY())
			return false;
		return true;
	}
	
	def public int getXinPixels(){
		return this.getX() * Gameboard.CELLZISE;
	}

	def public int getYinPixels(){
		return this.getY() * Gameboard.CELLZISE;
	}	
	
	def public void incX(int spaces){
		this.setX(this.getX() + spaces);
	}
	def public void incY(int spaces){
		this.setY(this.getY() + spaces);
	}		
}