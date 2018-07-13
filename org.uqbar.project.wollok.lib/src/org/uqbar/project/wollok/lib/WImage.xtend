package org.uqbar.project.wollok.lib

import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

class WImage extends Image {
	WollokObject object
	
	new(WollokObject wObject) {
		this.object = wObject
	}
	
	override getPath() { 
		object.asString
	}
}
