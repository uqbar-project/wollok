
object wgame{
	method addVisual(element) native
	method addVisualCharacter(element) native
	method addVisualWithReference(element, property) native
	method whenKeyPressedDo(key, action) native
	method whenCollideDo(element, action) native
	method getObjectsIn(posX, posY) native
	method start() native
	
	method setTittle(tittle) native
	method getTittle() native
	method setWidth(cant) native
	method getWidth() native
	method setHeight(cant) native
	method getHeight() native
}

class Position {
	var x = 0
	var y = 0
	
	new() { }
	
	new(_x, _y) {
		x = _x
		y = _y
	}
	
	method moveLeft(num) {
		x = x - num
	}
	method moveRight(num) {
		x = x + num
	}
	method moveDown(num) {
		y = y - num
	}
	method moveUp(num) {
		y = y + num
	}
	
	method getX() {
		return x
	}
	method setX(_x) {
		x = _x
	}
	method getY() {
		return y
	}
	method setY(_y) {
		y = _y
	}
}

class GameException extends wollok.lang.Exception {

	var message
 
	new(_message) {
		message = _message
	}
}