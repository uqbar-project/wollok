
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
	method getX() native
	method setX(x) native
	method getY() native
	method setY(y) native
	method setWollokObject(anObject) native
	method sendMessage() native
}