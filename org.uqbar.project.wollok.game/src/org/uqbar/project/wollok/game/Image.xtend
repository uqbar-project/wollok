package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

@Accessors
class Image {
	ImageSize size = new TextureSize
	String path

	WollokObject object

	new(WollokObject wObject) {
		this.object = wObject
	}

	def getPath() {
		path ?: object.wollokToJava(String) as String
	}

	new(String path) {
		this.path = path
	}

	override public int hashCode() {
		val prime = 31
		prime + getPath.hashCode
	}

	override equals(Object obj) {
		if(obj === null) return false

		val other = obj as Image
		getPath == other.getPath
	}
}
