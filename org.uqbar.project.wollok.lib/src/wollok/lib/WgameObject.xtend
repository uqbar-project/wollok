package wollok.lib

import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.KeyboardListener
import org.uqbar.project.wollok.game.listeners.CollisionListener
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import static extension wollok.lib.Position.*

/**
 * 
 * @author ?
 */
class WgameObject {
	def addVisual(WollokObject it) { position.drawWollokElement(it) }
	
	def addVisualCharacter(WollokObject it) { position.drawWollokCharacter(it) }
	
	def whenKeyPressedDo(WollokObject key, WollokObject action) {
		var num = key.asInteger
		val function = action.asClosure
		var listener = new KeyboardListener(num, [ function.doApply ])
		board.addListener(listener)
	}

	def whenKeyPressedSay(WollokObject key, WollokObject functionObj) {	
		val num = key.asInteger
		val function = functionObj.asClosure
		var listener = new KeyboardListener(num,  [ board.characterSay(function.doApply.asString) ]) 
		board.addListener(listener)
	}
	
	def whenCollideDo(WollokObject object, WollokObject action) {
		val visualObject = board.getComponents().findFirst[ c | c.domainObject.equals(object)]
		val function = action.asClosure
		val listener = new CollisionListener(visualObject, [ VisualComponent e | function.doApply(e.domainObject) ])
		board.addListener(listener)
	}
	
	def clear() { board.clear }
	
	def start() { board.start }
	
	def board() { Gameboard.getInstance }
	
	def addCharacter(VisualComponent component) {
		board.addCharacter(component)
	}
	
	def addComponent(VisualComponent component) {
		board.addComponent(component)
	}
	
//	 ACCESSORS
	def getTitle() { board.title.javaToWollok }
	def setTitle(WollokObject title) {
		board.title = title.asString
	}
	
	def getWidth() { board.width.javaToWollok }
	def setWidth(WollokObject cant) {
		board.width =  cant.asInteger
	}
	
	def getHeight() { board.height.javaToWollok }
	def setHeight(WollokObject cant) {
		board.height = cant.asInteger
	}
	
	def setGround(WollokObject image) {
		board.createCells(image.asString)
	}
}