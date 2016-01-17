package wollok.lib

import java.util.List
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.KeyboardListener
import org.uqbar.project.wollok.game.listeners.CollisionListener
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

/**
 * 
 * @author ?
 */
class WgameObject {
	public static val CONVENTIONS = #["posicion", "position"]
	
	@NativeMessage("addVisual")
	def addVisualMethod(Object it) { addComponent(asVisualComponent) }
	
	@NativeMessage("addVisualCharacter")
	def addVisualCharacterMethod(Object it) { addCharacter(asVisualComponent) }

	def asVisualComponent(Object it) { 
		var wObj = it as WollokObject
		new VisualComponent(new WPosition(wObj.position), new WImage(wObj), wObj)
	}
	
	def getPosition(WollokObject it) {
		var method = allMethods.map[it.name].findFirst[isPositionGetter]
		if (method != null)
			return call(method)

		var position = CONVENTIONS.map[c|instanceVariables.get(c)].filterNull.head
		if (position != null)
			return position

		throw new WollokRuntimeException(String.format("Visual object doesn't have any position: %s", it.toString))
	}

	def isPositionGetter(String it) {
		CONVENTIONS.map[#[it, "get" + it.toFirstUpper]].flatten.toList.contains(it)
	}
	
	def wollokToList(Object it) { 
		WollokObject.cast(it).wollokToJava(List) as List
	}
	
	def asVisualComponent(Object it, List<String> attrs) { 
		asVisualComponent => [
			attributes = attrs
		]
	}
	
	@NativeMessage("addVisualWithReference")
	def addVisualWithReferenceMethod(Object it, Object properties) {
		addComponent(asVisualComponent(properties.wollokToList))
	}

	@NativeMessage("whenKeyPressedSay")
	def whenKeyPressedSayMethod(Object key, WollokObject functionObj) {	
		val num = WollokObject.cast(key).wollokToJava(Integer) as Integer
		val function = functionObj.asClosure
		var listener = new KeyboardListener(num,  [ Gameboard.getInstance.characterSay(function.doApply.wollokToJava(String) as String) ]) 
		board.addListener(listener)
	}
	
	@NativeMessage("addVisualCharacterWithReference")
	def addVisualCharacterWithReferenceMethod(Object element, Object properties) {		
		addCharacter(asVisualComponent(properties.wollokToList))
	}
	
	@NativeMessage("whenKeyPressedDo")
	def whenKeyPressedDoMethod(Object key, WollokObject action) {
		var num = WollokObject.cast(key).wollokToJava(Integer) as Integer
		val function = action.asClosure
		var listener = new KeyboardListener(num, [ function.doApply ])
		board.addListener(listener)
	}

	@NativeMessage("whenCollideDo")
	def whenCollideDoMethod(Object object, WollokObject action) {
		val visualObject = board.getComponents().findFirst[ c | c.domainObject.equals(WollokObject.cast(object))]
		val function = action.asClosure
		val listener = new CollisionListener(visualObject, [ VisualComponent e | function.doApply(e.domainObject) ])
		board.addListener(listener)
	}
	
	@NativeMessage("getObjectsIn")
	def getObjectsInMethod(Object position) {
		val wollokObject = position as WollokObject
		val wPosition = new WPosition(wollokObject) 
		val list = board.getComponentsInPosition(wPosition).map[ domainObject ].toList
		list.javaToWollok
	}
	
	@NativeMessage("clear")
	def clearMethod() { board.clear }
	
	@NativeMessage("start")
	def startMethod() { board.start }
	
	def board() { Gameboard.getInstance }
	
	def addCharacter(VisualComponent component) {
		board.addCharacter(component)
	}
	
	def addComponent(VisualComponent component) {
		board.addComponent(component)
	}
	
//	 ACCESSORS
	@NativeMessage("setTitle")
	def setTittleMethod(String title) {
		board.title = title.wollokToJava(String) as String
	}
	
	@NativeMessage("getTitle")
	def getTittleMethod() { board.title.javaToWollok }
	
	@NativeMessage("setWidth")
	def setWeightMethod(WollokObject cant) {
		board.width =  cant.wollokToJava(Integer) as Integer
	}
		
	@NativeMessage("getWidth")
	def getWeightMethod() { board.width.javaToWollok }
	
	@NativeMessage("setHeight")
	def setHeightMethod(WollokObject cant) {
		board.height = cant.wollokToJava(Integer) as Integer
	}
	
	@NativeMessage("getHeight")
	def getHeightMethod() { board.height.javaToWollok }
	
	@NativeMessage("setGround")
	def setGroundMethod(WollokObject image) {
		board.createCells(image.wollokToJava(String) as String)
	}
}