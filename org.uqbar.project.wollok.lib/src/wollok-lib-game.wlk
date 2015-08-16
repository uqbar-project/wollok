
object wgame{
		method getGameboard() native
		method setTittle(tittle) native
		method getTittle() native
		method setWeight(cant) native
		method getWeight() native
		method setHeight(cant) native
		method getHeight() native
		method addObject(wollokObject, image, posX, posY) native
		method getObjectsIn(posX, posY) native
	}

class Position { 
	method getX() native
	method setX(x) native
	method getY() native
	method setY(y) native
	method setWollokObject(anObject) native
	method sendMessage() native
}