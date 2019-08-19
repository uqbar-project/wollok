package wollok.game

import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.game.WPosition
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.CollisionListener
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.game.listeners.InstantCollisionListener
import org.uqbar.project.wollok.game.listeners.KeyboardListener
import org.uqbar.project.wollok.game.listeners.TimeListener
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.game.helpers.WollokConventionExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.checkNotNull

/**
 * 
 * @author ?
 */
class GameObject {
	
	def addVisual(WollokObject it) {
		checkNotNull("addVisual") 
		board.addComponent(asVisual)
	}

	def addVisualIn(WollokObject it, WollokObject position) {
		checkNotNull("addVisualIn")
		position.checkNotNull("addVisualIn") 
		board.addComponent(asVisualIn(position))
	}
	
	def addVisualCharacter(WollokObject it) {
		checkNotNull("addVisualCharacter") 
		board.addCharacter(asVisual)
	}
	
	def addVisualCharacterIn(WollokObject it, WollokObject position) {
		checkNotNull("addVisualCharacterIn")
		position.checkNotNull("addVisualCharacterIn") 
		board.addCharacter(asVisualIn(position))
	}
	
	def removeVisual(WollokObject it) {
		checkNotNull("removeVisual")
		var visual = board.findVisual(it)
		board.remove(visual)
	}
	
	def onTick(WollokObject milliseconds, WollokObject name, WollokObject action) {
		milliseconds.checkNotNull("onTick")
		name.checkNotNull("onTick")
		action.checkNotNull("onTick")
		val function = action.asClosure
		addListener(new TimeListener(name.asString, milliseconds.coerceToInteger, [ function.doApply ]))
	}
	
	def removeTickEvent(WollokObject name) {
		name.checkNotNull("removeTickEvent")
		board.removeListener(name.asString)
	}
	
	def whenKeyPressedDo(WollokObject key, WollokObject action) {
		key.checkNotNull("whenKeyPressedDo")
		action.checkNotNull("whenKeyPressedDo")
		var num = key.coerceToInteger
		val function = action.asClosure
		addListener(new KeyboardListener(num, [ function.doApply ]))
	}

	def whenKeyPressedSay(WollokObject key, WollokObject functionObj) {
		val num = key.coerceToInteger
		val function = functionObj.asClosure
		addListener(new KeyboardListener(num, [ board.characterSay(function.doApply.asString) ]))
	}
	
	def whenCollideDo(WollokObject visual, WollokObject action) {
		visual.checkNotNull("whenCollideDo")
		action.checkNotNull("whenCollideDo")
		var visualObject = board.findVisual(visual)
		val function = action.asClosure
		addListener(new CollisionListener(visualObject, [ function.doApply(it.WObject) ]))
	}
	
	def onCollideDo(WollokObject visual, WollokObject action) {
		visual.checkNotNull("onCollideDo")
		action.checkNotNull("onCollideDo")
		var visualObject = board.findVisual(visual)
		val function = action.asClosure
		addListener(new InstantCollisionListener(visualObject, [ function.doApply(it.WObject) ]))
	}
	
	def getObjectsIn(WollokObject position) {
		position.checkNotNull("getObjectsIn")
		board
			.getComponentsInPosition(new WPosition(position))
			.map [ it.WObject ]
			.toList.javaToWollok
	}
	
	def colliders(WollokObject visual) {
		visual.checkNotNull("colliders")
		val visualObject = board.findVisual(visual)
		board.getComponentsInPosition(visualObject.position)
			.filter [ !it.equals(visualObject)]
			.map [ it.WObject ]
			.toList.javaToWollok
	}
		
	def say(WollokObject visual, String message) {
		visual.checkNotNull("say")
		board.findVisual(visual).say(message ?: "")
	}
	
	def hideAttributes(WollokObject visual) {
		visual.checkNotNull("hideAttributes")
		board.findVisual(visual).hideAttributes()
	}
	
	def void errorReporter(WollokObject visual) {
		visual.checkNotNull("errorReporter")
		board.errorReporter(board.findVisual(visual))
	}
	
	def showAttributes(WollokObject visual) {
		visual.checkNotNull("showAttributes")
		board.findVisual(visual).showAttributes()
	}
	
	def clear() { board.clear }
	
	def doStart(Boolean isRepl) {
		isRepl.checkNotNull("doStart") 
		board.start(isRepl)
	}
	
	def stop() { board.stop }
	
	def board() { Gameboard.getInstance }
	
	def addListener(GameboardListener listener) {
		listener.checkNotNull("addListener")
		board.addListener(listener)
	}
	
	def findVisual(Gameboard it, WollokObject visual) {
		val result = components.findFirst[ WObject.equals(visual)]
		
		if (result === null)
			throw new WollokProgramExceptionWrapper(evaluator.newInstance(EXCEPTION) => [
				setReference("message", NLS.bind(Messages.WollokGame_VisualComponentNotFound, visual).javaToWollok)	
			])
			
		result
	}
	
	def sound(String audioFile) {
		board.sound(audioFile)
	}
		
//	 ACCESSORS
	def title() { board.title }
	def title(String title) { board.title = title ?: "" }
	
	def width() { board.width.javaToWollok }
	def width(WollokObject cant) {
		cant.checkNotNull("width")
		board.width = cant.coerceToInteger
	}
	
	def height() { board.height.javaToWollok }
	def height(WollokObject cant) {
		cant.checkNotNull("height")
		board.height = cant.coerceToInteger
	}
	
	def ground(String image) { board.ground = image }
	def boardGround(String image) { board.boardGround = image }
	
}
