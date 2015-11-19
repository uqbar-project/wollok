package wollok.lib

import java.util.List
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.WPosition
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.CollisionListener
import org.uqbar.project.wollok.game.listeners.KeyboardListener
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.game.listeners.CharacterSayListener
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class WgameObject extends AbstractWollokDeclarativeNativeObject {
	
	@NativeMessage("addVisual")
	def addVisualMethod(Object element) {		
		var wollokObject = WollokObject.cast(element)
		this.addComponent(new VisualComponent(wollokObject))
	}
	
	@NativeMessage("addVisualCharacter")
	def addVisualCharacterMethod(Object object) {
		var wollokObject = WollokObject.cast(object)
		this.addCharacter(new VisualComponent(wollokObject))
	}
	
	@NativeMessage("addVisualWithReference")
	def addVisualWithReferenceMethod(Object element, Object properties) {		
		var wollokObject = WollokObject.cast(element)
		var wollokList = WollokObject.cast(properties)
		this.addComponent(new VisualComponent(wollokObject, wollokList.wollokToJava(List) as List))
	}

	@NativeMessage("whenKeyPressedSay")
	def whenKeyPressedSayMethod(Object key, WollokClosure function) {	
		var num = WollokObject.cast(key).wollokToJava(Integer) as Integer
		var listener = new CharacterSayListener(num,  [ | return function.apply().wollokToJava(String) as String ])
		Gameboard.getInstance().addListener(listener)
	}
	
	@NativeMessage("addVisualCharacterWithReference")
	def addVisualCharacterWithReferenceMethod(Object element, Object properties) {		
		var wollokObject = WollokObject.cast(element)
		var wollokList = WollokObject.cast(properties)
		this.addCharacter(new VisualComponent(wollokObject, wollokList.wollokToJava(List) as List))
	}
	
	@NativeMessage("whenKeyPressedDo")
	def whenKeyPressedDoMethod(Object key, WollokClosure action) {
		var num = WollokObject.cast(key).wollokToJava(Integer) as Integer
		var listener = new KeyboardListener(num, [ | action.apply() ])
		Gameboard.getInstance().addListener(listener)
	}

	@NativeMessage("whenCollideDo")
	def whenCollideDoMethod(Object object, WollokClosure action) {
		var visualObject = Gameboard.getInstance().getComponents().findFirst[ c | c.domainObject.equals(WollokObject.cast(object))]
		var listener = new CollisionListener(visualObject, [ e | action.apply(e.domainObject) ])
		Gameboard.getInstance().addListener(listener)
	}
	
	@NativeMessage("getObjectsIn")
	def getObjectsInMethod(Object position) {
		var wollokObject = WollokObject.cast(position)
		var wPosition = new WPosition(wollokObject)
		var list = Gameboard.getInstance().getComponentsInPosition(wPosition).map[ it.domainObject ].toList
		list.javaToWollok
	}
	
	@NativeMessage("clear")
	def clearMethod() {
		Gameboard.getInstance().clear()
	}
	
	@NativeMessage("start")
	def startMethod() {
		Gameboard.getInstance().start()
	}
	
	def addCharacter(VisualComponent component) {
		Gameboard.getInstance().addCharacter(component)
	}
	
	def addComponent(VisualComponent component) {
		Gameboard.getInstance().addComponent(component)
	}
	
	// accessors
	@NativeMessage("setTittle")
	def setTittleMethod(String title) {
		Gameboard.getInstance().title = title.wollokToJava(String) as String
	}
	
	@NativeMessage("getTittle")
	def getTittleMethod() {
		Gameboard.getInstance().tittle.javaToWollok
	}
	
	@NativeMessage("setWidth")
	def setWeightMethod(WollokObject cant) {
		Gameboard.getInstance().width =  cant.wollokToJava(Integer) as Integer
	}
		
	@NativeMessage("getWidth")
	def getWeightMethod() {
		Gameboard.getInstance().width.javaToWollok
	}
	
	@NativeMessage("setHeight")
	def setHeightMethod(WollokObject cant) {
		Gameboard.getInstance().height = cant.wollokToJava(Integer) as Integer
	}
	
	@NativeMessage("getHeight")
	def getHeightMethod() {
		Gameboard.getInstance().height.javaToWollok
	}
	
}