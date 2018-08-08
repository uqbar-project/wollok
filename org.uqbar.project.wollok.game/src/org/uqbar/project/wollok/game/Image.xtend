package org.uqbar.project.wollok.game

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Image {
	ImageSize size = new TextureSize
	String path
	
	new () { }
	
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
