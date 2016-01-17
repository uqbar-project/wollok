package wollok.lib

import java.util.List

import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.VisualComponent

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class Position extends org.uqbar.project.wollok.game.Position {
	public static val CONVENTIONS = #["posicion", "position"]

	def static getPosition(WollokObject it) {
		var method = allMethods.map[it.name].findFirst[isPositionGetter]
		if (method != null)
			return call(method)

		var position = CONVENTIONS.map[c|instanceVariables.get(c)].filterNull.head
		if (position != null)
			return position

		throw new WollokRuntimeException(String.format("Visual object doesn't have any position: %s", it.toString))
	}

	def static isPositionGetter(String it) {
		CONVENTIONS.map[#[it, "get" + it.toFirstUpper]].flatten.toList.contains(it)
	}
	
	def static drawWollokElement(WollokObject it, WollokObject visual) {
		call("drawElement", visual.javaToWollok)
	}

	def static drawWollokCharacter(WollokObject it, WollokObject visual) {
		call("drawCharacter", visual.javaToWollok)
	}
	
	
	def moveDown(WollokObject cant) { incY(-cant.wollokToInt)}
	def moveUp(WollokObject cant) { incY(cant.wollokToInt)}
	def moveLeft(WollokObject cant) { incX(-cant.wollokToInt)}
	def moveRight(WollokObject cant) { incX(cant.wollokToInt)}
	
	def drawElement(WollokObject it) {
		board.addComponent(asVisualComponent)
	}

	def drawCharacter(WollokObject it) {
		board.addCharacter(asVisualComponent)		
	}

	def getAllElements() {
		board.getComponentsInPosition(this).map[ domainObject ].toList
	}
	
	def asVisualComponent(WollokObject it) { 
		new VisualComponent(this, new WImage(it), it)
	}
	
	def asVisualComponent(WollokObject it, List<String> attrs) { 
		asVisualComponent => [
			attributes = attrs
		]
	}

	def getBoard() { Gameboard.getInstance }

	def setNativeX(WollokObject wX) {
		x = wX.wollokToInt
	}
	
	def setNativeY(WollokObject wY) {
		y = wY.wollokToInt
	}
	
	def getNativeX() { x.javaToWollok }
	def getNativeY() { y.javaToWollok }
	
	def wollokToInt(WollokObject it) {wollokToJava(Integer) as Integer }
}
