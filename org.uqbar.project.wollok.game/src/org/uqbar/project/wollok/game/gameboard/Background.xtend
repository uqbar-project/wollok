package org.uqbar.project.wollok.game.gameboard

import java.util.List
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.GameSize
import org.eclipse.xtend.lib.annotations.Accessors

interface Background {	
	def void draw(Window window)	
}

@Accessors
class CellsBackground implements Background {
	val List<Cell> cells = newArrayList
	
	new(String image, Gameboard it) {
		for (var i = 0; i < width ; i++) {
			for (var j = 0; j < height; j++) {
				cells.add(new Cell(new WGPosition(i, j), new Image(image)));
			}
		}
	}
	
	override draw(Window window) {
		cells.forEach[ it.draw(window) ]
	}
	
}

@Accessors
class FullBackground implements Background {
	val Image image
	
	new(String path, Gameboard game) {
		image = new Image(path) => [ size = new GameSize(game)]
	}
	
	override draw(Window window) {
		window.draw(image)
	}
	
} 