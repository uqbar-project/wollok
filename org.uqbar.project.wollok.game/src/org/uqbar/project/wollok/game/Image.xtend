package org.uqbar.project.wollok.game

import org.uqbar.project.wollok.interpreter.core.WollokObject
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.Texture.TextureFilter
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class Image {
	
	String path
	protected String currentPath
	Texture texture
	
	new() { }
	
	new(String path) {
		this.path = path
		this.currentPath = path
	}
	
	def getPath() { path }
	
	
	def getTexture() {
		if (this.texture == null || this.currentPath != this.getPath()) {
			this.texture = new Texture(Gdx.files.internal(this.getPath()))
			this.texture.setFilter(TextureFilter.Linear, TextureFilter.Linear)
			this.currentPath = this.getPath()
		}
		
		return this.texture
	}
}

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