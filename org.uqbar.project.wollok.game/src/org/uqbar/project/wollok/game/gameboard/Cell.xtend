package org.uqbar.project.wollok.game.gameboard

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.CellSize
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.Position

@Accessors
class Cell {
	var Image image
	var Position position

	new(Position position, Image image) {
		this.position = position
		this.image = image => [ size = new CellSize(Gameboard.instance.CELLZISE) ]
	}
	
	def draw(Window window) {
		window.draw(image, position)
	}	
}