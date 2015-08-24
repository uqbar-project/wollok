package wollok.lib

import org.uqbar.project.wollok.interpreter.nativeobj.WollokInteger
import org.uqbar.project.wollok.interpreter.core.WollokObject

class Position {
	var int x  
	var int y
	var WollokObject myObject;
		
	def getX() {
		return new WollokInteger(x);
	}
	
	def setX(int x) {
		this.x = x;
	}
	
	def getY() {
		return new WollokInteger(y);
	}
	
	def setY(int y) {
		this.y = y;
	}	
	
	def setWollokObject(Object anObject){
		System.out.println("Este objeto es " + anObject.class.name);
		this.myObject = WollokObject.cast(anObject) 
		
	}
	def sendMessage(){
		this.myObject.call("sayMyName")
	}
}	