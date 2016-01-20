package wollok.lib

import org.uqbar.project.wollok.lib.WVisual
import org.uqbar.project.wollok.lib.WPosition
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.KeyboardListener
import org.uqbar.project.wollok.game.listeners.CollisionListener
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

/**
 * 
 * @author ?
 */
class WgameObject {
	
	def addVisual(WollokObject it) { 
		board.addComponent(asVisual)
	}

	def addVisualIn(WollokObject it, WollokObject position) { 
		board.addComponent(asVisualIn(position))
	}
	
	def addVisualCharacter(WollokObject it) { 
		board.addCharacter(asVisual)
	}
	
	def addVisualCharacterIn(WollokObject it, WollokObject position) { 
		board.addCharacter(asVisualIn(position))
	}
	
	def whenKeyPressedDo(WollokObject key, WollokObject action) {
		var num = key.asInteger
		val function = action.asClosure
		var listener = new KeyboardListener(num, [ function.doApply ])
		addListener(listener)
	}

	def whenKeyPressedSay(WollokObject key, WollokObject functionObj) {	
		val num = key.asInteger
		val function = functionObj.asClosure
		var listener = new KeyboardListener(num,  [ board.characterSay(function.doApply.asString) ]) 
		addListener(listener)
	}
	
	def whenCollideDo(WollokObject object, WollokObject action) {
		var components = board.components.map[it as WVisual] 
		val visualObject = components.findFirst[ it.wObject.equals(object)]
		val function = action.asClosure
		val listener = new CollisionListener(visualObject, [ function.doApply((it as WVisual).wObject) ])
		addListener(listener)
	}
	
	def getObjectsIn(WollokObject position) {
		var pos = new WPosition(position)
		board.getComponentsInPosition(pos)
		.map[ it as WVisual ]
		.map [ it.wObject ]
		.toList.javaToWollok
	}
	
	def clear() { board.clear }
	
	def start() { board.start }
	
	def board() { Gameboard.getInstance }
	
	def addListener(GameboardListener listener) {
		board.addListener(listener)
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