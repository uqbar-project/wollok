package wollok.lib

import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

class WImage extends Image {
	public static val CONVENTIONS = #["imagen", "image"]

	def static getImage(WollokObject it) {
		findConvention(CONVENTIONS)
	}
		
	WollokObject object
	
	new(WollokObject wObject) {
		this.object = wObject
		this.currentPath = this.getPath()
	}
	
	override getPath() { 
		object.getImage.asString
	}
}