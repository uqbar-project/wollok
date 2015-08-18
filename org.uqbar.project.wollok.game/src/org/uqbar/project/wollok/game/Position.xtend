package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard

@Accessors
class Position {
	private int x;
	private int y;
	
	
	new(int x, int y) {
		this.x = x;
		this.y = y;
	}
	
	
	override public int hashCode() {
		val int prime = 31;
		var int result = 1;
		result = prime * result + x;
		result = prime * result + y;
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
		if (x != other.x)
			return false;
		if (y != other.y)
			return false;
		return true;
	}
	
	def public int getXinPixels(){
		return x * Gameboard.CELLZISE;
	}

	def public int getYinPixels(){
		return y * Gameboard.CELLZISE;
	}	
	
	def public void incX(int spaces){
		this.x = this.x + spaces;
	}
	def public void incY(int spaces){
		this.y = this.y + spaces;
	}		
}