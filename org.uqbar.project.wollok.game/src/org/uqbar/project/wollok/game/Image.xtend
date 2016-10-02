package org.uqbar.project.wollok.game

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.Texture.TextureFilter

class Image {
	
	String path
	protected String currentPath
	Texture texture
	
	new() { 
		this.currentPath = path
	}
	
	new(String path) {
		this.path = path
	}
	
	def getPath() { path }
	
	
	def getTexture() {
		if (this.texture == null || this.currentPath != this.path) {
			var file = Gdx.files.internal(this.getPath())
			
			if (!file.exists) return null			
				
			this.texture = new Texture(file)
			this.texture.setFilter(TextureFilter.Linear, TextureFilter.Linear)
			this.currentPath = this.getPath()
		}
		
		return this.texture
	}
	
	override public int hashCode() {
		val prime = 31
		prime + getPath.hashCode
	}

	override equals(Object obj) {
		if(obj == null) return false

		var other = obj as Image
		getPath == other.getPath
	}
}