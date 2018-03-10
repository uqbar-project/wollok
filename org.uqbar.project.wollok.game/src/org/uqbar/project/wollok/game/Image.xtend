package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.Gameboard

@Accessors
class Image {
	var int width = Gameboard.CELLZISE
	var int height = Gameboard.CELLZISE
	String path
	protected String currentPath
	
	new() { 
		this.currentPath = path
	}
	
	new(String path) {
		this.path = path
	}
	
	def getPath() { path }
	
	override public int hashCode() {
		val prime = 31
		prime + getPath.hashCode
	}

	override equals(Object obj) {
		if(obj == null) return false

		var other = obj as Image
		getPath == other.getPath
	}
}