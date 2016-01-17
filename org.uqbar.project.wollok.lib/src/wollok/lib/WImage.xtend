package wollok.lib

import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class WImage extends Image {
		
	WollokObject object
	
	new(WollokObject wObject) {
		this.object = wObject
		this.currentPath = this.getPath()
	}
	
	override getPath() { 
		this.object.call("getImagen").wollokToJava(String) as String
	}
}